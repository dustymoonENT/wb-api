defmodule MotivusWbApi.Processing.Actions do
  @moduledoc """
  Actions common for handling task processing.

  Provides a high level description of what to do whenever a new event arrives. Used closely with event listeners.

  This module generally interacts with PubSub, Pools, Registries and the database.
  """
  alias Phoenix.PubSub
  alias MotivusWbApi.Repo
  alias MotivusWbApi.Users.User
  alias MotivusWbApi.Processing
  alias MotivusWbApi.Stats
  alias MotivusWbApi.Users
  alias MotivusWbApi.TaskPool.TaskDefinition
  alias MotivusWbApi.TaskPool.Task
  alias MotivusWbApi.ThreadPool.Thread
  alias MotivusWbApiWeb.Channels.Worker.Result

  @redacted_task_data [
    :client_channel_id,
    :client_id,
    :task_id,
    :application_token_id,
    :ref,
    :__struct__
  ]

  @typedoc """
  A map that contains the process information. The module can be used along the process id to call their functions, where many module instances are currently running, the process id targets an specific instance of that module.
  """
  @type process() :: %{module: module(), id: atom()}

  @spec task_from_definition(TaskDefinition.t()) :: Processing.Task.t()
  def task_from_definition(%TaskDefinition{} = task_def),
    do: %Processing.Task{
      type: task_def.body["run_type"],
      params: %{data: task_def.body["params"]},
      date_in: DateTime.truncate(DateTime.utc_now(), :second),
      attempts: 0,
      processing_base_time: task_def.body["processing_base_time"],
      flops: task_def.body["flops"],
      flop: task_def.body["flop"],
      client_id: task_def.client_id,
      security_level: task_def.security_level
    }

  @spec prepare_task(TaskDefinition.t()) :: Task.t()
  def prepare_task(%TaskDefinition{} = task_def) do
    %{id: task_id} =
      task_from_definition(task_def)
      |> Repo.insert!()

    struct!(Task, Map.from_struct(task_def) |> Enum.into(%{task_id: task_id}))
  end

  @spec add_task(Task.t(), process()) :: no_return()
  def add_task(%Task{} = task, %{module: pool, id: pool_id}), do: pool.push(pool_id, task)

  @spec remove_tasks(String.t(), process()) :: [Task.t()]
  def remove_tasks(channel_id, %{module: pool, id: pool_id}), do: pool.drop(pool_id, channel_id)

  @spec maybe_match_task_to_thread(String.t()) :: :ok
  def maybe_match_task_to_thread(scope),
    do: PubSub.broadcast(MotivusWbApi.PubSub, "matches:" <> scope, {"POOL_UPDATED", %{}})

  @spec maybe_stop_tasks(String.t(), process()) :: [Task.t()]
  def maybe_stop_tasks(channel_id, %{module: pool, id: pool_id}) do
    pool.drop_by(pool_id, :client_channel_id, channel_id)
    |> Enum.map(fn {worker_channel_id, tid, task} ->
      abort_task!(worker_channel_id, tid)

      task
    end)
  end

  @spec mark_aborted_tasks([Task.t()]) :: {integer(), [Processing.Task.t()]}
  def mark_aborted_tasks(tasks),
    do:
      tasks
      |> Enum.map(& &1.task_id)
      |> Processing.update_many_task(aborted_on: DateTime.truncate(DateTime.utc_now(), :second))

  @spec abort_task!(String.t(), String.t()) :: :ok
  def abort_task!(channel_id, tid),
    do: PubSub.broadcast(MotivusWbApi.PubSub, "node:" <> channel_id, {"TASK_ABORTED", tid})

  @spec register_thread(Thread.t(), process()) :: no_return()
  def register_thread(%Thread{} = thread, %{module: pool, id: pool_id}),
    do: pool.push(pool_id, thread)

  @spec deregister_threads(String.t(), process()) :: [Task.t()]
  def deregister_threads(channel_id, %{module: pool, id: pool_id}),
    do: pool.drop(pool_id, channel_id)

  @spec drop_running_tasks(String.t(), process()) :: no_return()
  def drop_running_tasks(channel_id, %{module: registry, id: registry_id}) do
    case registry.drop(registry_id, channel_id) do
      {:ok, tasks} ->
        tasks
        |> Enum.each(fn {_tid, t} ->
          PubSub.broadcast(MotivusWbApi.PubSub, "tasks", {"UNFINISHED_TASK", t})
        end)

      _ ->
        nil
    end
  end

  @spec broadcast_user_stats(String.t()) :: :ok | {:error, term()}
  def broadcast_user_stats(channel_id) do
    [user_uuid, _] = channel_id |> String.split(":")
    user = Repo.get_by!(Users.User, uuid: user_uuid)

    current_season = Stats.get_current_season(DateTime.utc_now())

    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "node:" <> channel_id,
      {"WORKER_STATS_UPDATED",
       %{
         uid: 1,
         body:
           Stats.get_user_stats(user.id, current_season)
           |> Map.merge(Stats.get_cluster_stats()),
         type: "stats"
       }}
    )
  end

  @spec try_match(process(), process(), String.t()) :: nil | no_return() | :ok
  def try_match(
        %{module: thread_pool, id: thread_pool_id},
        %{module: task_pool, id: task_pool_id},
        scope
      ) do
    case [thread_pool.pop(thread_pool_id), task_pool.pop(task_pool_id)] do
      [:error, :error] ->
        nil

      [%Thread{} = thread, :error] ->
        thread_pool.push_top(thread_pool_id, thread)

      [:error, %Task{} = task] ->
        task_pool.push(task_pool_id, task)

      [%Thread{} = thread, %Task{} = task] ->
        assign_task_to_thread(thread, task, scope)
    end
  end

  @spec assign_task_to_thread(Thread.t(), Task.t(), String.t()) :: :ok
  def assign_task_to_thread(%Thread{} = thread, %Task{} = task, scope) do
    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "dispatch:" <> scope,
      {"TASK_ASSIGNED", %{thread: thread, task: task}}
    )
  end

  @spec update_task_worker(Task.t(), Thread.t()) :: {:ok, Processing.Task.t()} | {:error, map()}
  def update_task_worker(%Task{task_id: task_id}, %Thread{} = thread) do
    [user_uuid, _] = thread.channel_id |> String.split(":")

    task = Repo.get_by!(Processing.Task, id: task_id)
    user = Repo.get_by!(User, uuid: user_uuid)

    task
    |> Ecto.Changeset.change(%{
      date_last_dispatch: DateTime.truncate(DateTime.utc_now(), :second),
      attempts: task.attempts + 1,
      user_id: user.id
    })
    |> Repo.update()
  end

  @spec deliver_task(Task.t(), Thread.t()) :: :ok
  def deliver_task(%Task{} = task, %Thread{} = thread) do
    worker_input = task |> Map.put(:tid, thread.tid) |> Map.drop(@redacted_task_data)

    PubSub.broadcast!(
      MotivusWbApi.PubSub,
      "node:" <> thread.channel_id,
      {"WORKER_INPUT_READY", worker_input}
    )
  end

  @spec register_task_assignment(Task.t(), Thread.t(), process()) :: no_return()
  def register_task_assignment(%Task{} = task, %Thread{} = thread, %{
        module: registry,
        id: registry_id
      }),
      do: registry.put(registry_id, thread.channel_id, thread.tid, task)

  @spec deregister_task_assignment(Thread.t(), process()) :: Task.t()
  def deregister_task_assignment(%Thread{} = thread, %{module: registry, id: registry_id}) do
    {:ok, task} =
      registry.drop(
        registry_id,
        thread.channel_id,
        thread.tid
      )

    task
  end

  @spec update_task_result(Task.t(), Result.t()) :: Task.t()
  def update_task_result(%Task{} = task, %Result{} = _result) do
    Repo.get_by!(Processing.Task, id: task.task_id)
    |> Ecto.Changeset.change(%{
      date_out: DateTime.truncate(DateTime.utc_now(), :second)
      # result: result.body
    })
    |> Repo.update()

    task
  end

  @spec send_task_result(Task.t(), Result.t()) :: :ok
  def send_task_result(%Task{} = task, %Result{} = result) do
    PubSub.broadcast!(
      MotivusWbApi.PubSub,
      "client:" <> task.client_channel_id,
      {"TASK_RESULT_READY",
       %{
         type: "response",
         body: result.body,
         stdout: result.stdout,
         stderr: result.stderr,
         ref: task.ref,
         task_id: task.task_id
       }}
    )
  end

  @spec update_task_result_validation(non_neg_integer(), String.t(), boolean()) ::
          {:ok, Processing.Task.t()}
  def update_task_result_validation(task_id, client_id, is_valid) do
    Repo.get_by!(Processing.Task, id: task_id, client_id: client_id)
    |> Ecto.Changeset.change(%{is_valid: is_valid})
    |> Repo.update()
  end
end

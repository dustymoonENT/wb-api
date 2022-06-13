defmodule MotivusWbApi.CommonActions do
  alias Phoenix.PubSub
  alias MotivusWbApi.Repo
  alias MotivusWbApi.Processing
  alias MotivusWbApi.Stats
  alias MotivusWbApi.Users
  alias MotivusWbApi.TaskPool.TaskDefinition
  alias MotivusWbApi.TaskPool.Task
  alias MotivusWbApi.ThreadPool.Thread

  def task_from_definition(%TaskDefinition{} = task_def),
    do: %Processing.Task{
      type: task_def.body["run_type"],
      params: %{data: task_def.body["params"]},
      date_in: DateTime.truncate(DateTime.utc_now(), :second),
      attempts: 0,
      processing_base_time: task_def.body["processing_base_time"],
      flops: task_def.body["flops"],
      flop: task_def.body["flop"],
      client_id: task_def.client_id
    }

  def prepare_task(%TaskDefinition{} = task_def) do
    %{id: task_id} =
      task_from_definition(task_def)
      |> Repo.insert!()

    struct!(Task, Map.from_struct(task_def) |> Enum.into(%{task_id: task_id}))
  end

  def add_task(%Task{} = task, pool), do: pool.push(pool, task)

  def remove_tasks(channel_id, pool), do: pool.drop(pool, channel_id)

  def maybe_match_task_to_thread,
    do: PubSub.broadcast(MotivusWbApi.PubSub, "matches", {"maybe_match", :unused, %{}})

  def maybe_stop_tasks(channel_id, pool) do
    pool.drop_by(pool, :client_channel_id, channel_id)
    |> Enum.map(fn {worker_channel_id, tid, task} ->
      abort_task!(worker_channel_id, tid)

      task
    end)
  end

  def mark_aborted_tasks(tasks),
    do:
      tasks
      |> Enum.map(& &1.task_id)
      |> Processing.update_many_task(aborted_on: DateTime.truncate(DateTime.utc_now(), :second))

  def abort_task!(channel_id, tid),
    do:
      MotivusWbApiWeb.Endpoint.broadcast!(
        "room:worker:" <> channel_id,
        "abort_task",
        %{tid: tid}
      )

  def register_thread(%Thread{} = thread, pool), do: pool.push(pool, thread)

  def deregister_threads(channel_id, pool), do: pool.drop(pool, channel_id)

  def maybe_retry_dropped_tasks(channel_id, registry) do
    case registry.drop(registry, channel_id) do
      {:ok, tasks} ->
        tasks
        |> Enum.map(fn {_tid, t} ->
          PubSub.broadcast(MotivusWbApi.PubSub, "tasks", {"retry_task", :unused, t})
        end)

      _ ->
        nil
    end
  end

  def broadcast_user_stats(channel_id) do
    [user_uuid, _] = channel_id |> String.split(":")
    user = Repo.get_by!(Users.User, uuid: user_uuid)

    current_season = Stats.get_current_season(DateTime.utc_now())

    MotivusWbApiWeb.Endpoint.broadcast!(
      "room:worker:" <> channel_id,
      "stats",
      %{
        uid: 1,
        body:
          Stats.get_user_stats(user.id, current_season)
          |> Map.merge(Stats.get_cluster_stats()),
        type: "stats"
      }
    )
  end

  def match(thread_pool, task_pool) do
    case [thread_pool.pop(thread_pool), task_pool.pop(task_pool)] do
      [:error, :error] ->
        nil

      [%Thread{} = thread, :error] ->
        thread_pool.push_top(thread_pool, thread)

      [:error, %Task{} = task] ->
        task_pool.push(task_pool, task)

      [%Thread{} = thread, %Task{} = task] ->
        dispatch(thread, task)
    end
  end

  def dispatch(%Thread{} = thread, %Task{} = task) do
    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "dispatch",
      {"worker_task_match", :unused, %{data_node: thread, data_task: task}}
    )
  end
end

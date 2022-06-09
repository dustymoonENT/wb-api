defmodule MotivusWbApi.CommonActions do
  alias Phoenix.PubSub
  alias MotivusWbApi.Repo
  alias MotivusWbApi.Processing.Task
  alias MotivusWbApi.Processing
  alias MotivusWbApi.Stats
  alias MotivusWbApi.Users

  def task_from_data(data),
    do: %Task{
      type: data[:body]["run_type"],
      params: %{data: data[:body]["params"]},
      date_in: DateTime.truncate(DateTime.utc_now(), :second),
      attempts: 0,
      processing_base_time: data[:body]["processing_base_time"],
      flops: data[:body]["flops"],
      flop: data[:body]["flop"],
      client_id: data[:client_id],
      application_token_id: data[:application_token_id]
    }

  def enqueue_task(data, queue), do: queue.push(queue, data)

  def dequeue_tasks(channel_id, queue), do: queue.drop(queue, channel_id)

  def maybe_match_task_to_node,
    do: PubSub.broadcast(MotivusWbApi.PubSub, "matches", {"try_to_match", :unused, %{}})

  def maybe_stop_tasks(channel_id, queue) do
    queue.drop_by(queue, :client_channel_id, channel_id)
    |> Enum.map(fn {worker_channel_id, tid, task} ->
      abort_task!(worker_channel_id, tid)

      task
    end)
  end

  def prepare_task(data) do
    task =
      task_from_data(data)
      |> Repo.insert!()

    data |> Map.put(:task_id, task.id) |> Map.put(:client_channel_id, data.client_channel_id)
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

  def register_thread(info, queue), do: queue.push(queue, info)

  def deregister_threads(channel_id, queue), do: queue.drop(queue, channel_id)

  def maybe_retry_dropped_tasks(channel_id, queue) do
    case queue.drop(queue, channel_id) do
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
end

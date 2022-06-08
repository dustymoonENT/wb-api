defmodule MotivusWbApi.ListenerTasks do
  use GenServer
  alias Phoenix.PubSub
  alias MotivusWbApi.Repo
  alias MotivusWbApi.Processing.Task
  alias MotivusWbApi.Processing

  @queue_tasks MotivusWbApi.QueueTasks
  @queue_processing MotivusWbApi.QueueProcessing

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "tasks")
    {:ok, opts}
  end

  defp task_from_data(data),
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

  defp enqueue_task(data), do: @queue_tasks.push(@queue_tasks, data)

  defp dequeue_tasks(channel_id), do: @queue_tasks.drop(@queue_tasks, channel_id)

  defp maybe_match_task_to_node,
    do: PubSub.broadcast(MotivusWbApi.PubSub, "matches", {"try_to_match", :unused, %{}})

  defp maybe_drop_tasks(channel_id) do
    @queue_processing.drop_by(@queue_processing, :client_channel_id, channel_id)
    |> Enum.map(fn {worker_channel_id, tid, task} ->
      abort_task!(worker_channel_id, tid)

      task
    end)
  end

  defp prepare_task(data) do
    task =
      task_from_data(data)
      |> Repo.insert!()

    data |> Map.put(:task_id, task.id) |> Map.put(:client_channel_id, data.client_channel_id)
  end

  def abort_task!(channel_id, tid),
    do:
      MotivusWbApiWeb.Endpoint.broadcast!(
        "room:worker:" <> channel_id,
        "abort_task",
        %{tid: tid}
      )

  # Callbacks

  def handle_info({"new_task", _name, data}, state) do
    prepare_task(data)
    |> enqueue_task()

    maybe_match_task_to_node()

    {:noreply, state}
  end

  def handle_info({"retry_task", _name, data}, state) do
    enqueue_task(data)
    maybe_match_task_to_node()

    {:noreply, state}
  end

  def handle_info({"dead_client", _name, %{channel_id: channel_id}}, state) do
    # TODO update tasks deregistered with aborted_on
    dequeue_tasks(channel_id)

    maybe_drop_tasks(channel_id)
    |> Enum.map(& &1.task_id)
    |> Processing.update_many_task(aborted_on: DateTime.truncate(DateTime.utc_now(), :second))

    {:noreply, state}
  end
end

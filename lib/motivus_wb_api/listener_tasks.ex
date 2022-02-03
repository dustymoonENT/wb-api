defmodule MotivusWbApi.ListenerTasks do
  use GenServer
  alias Phoenix.PubSub
  alias MotivusWbApi.Repo
  alias MotivusWbApi.Processing.Task
  alias MotivusWbApi.Processing

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    {:ok, {Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "tasks")}}
    |> IO.inspect(label: "Subscribed to tasks PubSub")
  end

  # Callbacks

  def handle_info({"new_task", _name, data}, state) do
    task =
      %Task{
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
      |> Repo.insert!()

    data =
      data |> Map.put(:task_id, task.id) |> Map.put(:client_channel_id, data.client_channel_id)

    MotivusWbApi.QueueTasks.push(MotivusWbApi.QueueTasks, data)
    PubSub.broadcast(MotivusWbApi.PubSub, "matches", {"try_to_match", :unused, %{}})
    {:noreply, state}
  end

  def handle_info({"retry_task", _name, data}, state) do
    MotivusWbApi.QueueTasks.push(MotivusWbApi.QueueTasks, data)
    PubSub.broadcast(MotivusWbApi.PubSub, "matches", {"try_to_match", :unused, %{}})
    {:noreply, state}
  end

  def handle_info({"dead_client", _name, %{channel_id: channel_id}}, state) do
    IO.inspect(label: "dead client")

    MotivusWbApi.QueueTasks.drop(MotivusWbApi.QueueTasks, channel_id)

    tasks =
      MotivusWbApi.QueueProcessing.drop_by(
        MotivusWbApi.QueueProcessing,
        :client_channel_id,
        channel_id
      )
      |> Enum.map(fn {worker_channel_id, tid, task} ->
        PubSub.broadcast(
          MotivusWbApi.PubSub,
          "tasks",
          {"abort_task", :unused, {worker_channel_id, tid, task}}
        )

        task
      end)

    task_ids =
      tasks
      |> Enum.map(& &1.task_id)

    Processing.update_many_task(task_ids,
      aborted_on: DateTime.truncate(DateTime.utc_now(), :second)
    )

    {:noreply, state}
  end

  def handle_info({"abort_task", _name, {channel_id, tid, _task}}, state) do
    MotivusWbApiWeb.Endpoint.broadcast!(
      "room:worker:" <> channel_id,
      "abort_task",
      %{tid: tid}
    )

    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch!(state, key), state}
  end
end

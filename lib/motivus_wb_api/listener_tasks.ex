defmodule MotivusWbApi.ListenerTasks do
  use GenServer
  alias Phoenix.PubSub
  alias MotivusWbApi.Repo
  alias MotivusWbApi.Processing.Task

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
        client_id: data[:client_id]
      }
      |> Repo.insert!()

    data = Map.put(data, :task_id, task.id)
    MotivusWbApi.QueueTasks.push(MotivusWbApi.QueueTasks, data)
    PubSub.broadcast(MotivusWbApi.PubSub, "matches", {"try_to_match", :hola, %{}})
    {:noreply, state}
  end

  def handle_info({"retry_task", _name, data}, state) do
    MotivusWbApi.QueueTasks.push(MotivusWbApi.QueueTasks, data)
    PubSub.broadcast(MotivusWbApi.PubSub, "matches", {"try_to_match", :hola, %{}})
    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch!(state, key), state}
  end
end

defmodule MotivusWbApi.ListenerDispatch do
  use GenServer
  alias Phoenix.PubSub

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    {:ok, {Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "dispatch")}}
     |> IO.inspect(label: "Subscribed to dispatch PubSub")
  end

  # Callbacks

  def handle_info({_topic, _name, %{"data_node": data_node, "data_task": data_task}}, state) do
    IO.inspect(label: "new dispatch")
    MotivusWbApi.QueueProcessing.put(MotivusWbApi.QueueProcessing, data_node[:id], data_task)
    MotivusWbApiWeb.Endpoint.broadcast!(
      "room:worker:" <> data_node[:id],
      "new_msg",
      data_task
    )
    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch!(state, key), state}
  end
end

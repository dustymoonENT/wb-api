defmodule MotivusWbApi.ListenerNodes do
  use GenServer
  alias Phoenix.PubSub

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    {:ok, {Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "nodes")}}
     |> IO.inspect(label: "Subscribed to nodes PubSub")
  end

  # Callbacks

  def handle_info({_topic, _name, data}, state) do
    IO.inspect(label: "new node")
    MotivusWbApi.QueueNodes.push(MotivusWbApi.QueueNodes, data)
    # Condicionado al la correcta ejecución del push
    PubSub.broadcast(MotivusWbApi.PubSub, "matches", {"try_to_match", :hola, %{}})
    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch!(state, key), state}
  end
end

defmodule MotivusWbApi.ListenerNodes do
  use GenServer
  alias Phoenix.PubSub
  alias MotivusWbApi.Stats

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    {:ok, {Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "nodes")}}
    |> IO.inspect(label: "Subscribed to nodes PubSub")
  end

  # Callbacks

  def handle_info({"new_node", _name, data}, state) do
    IO.inspect(label: "new node")

    MotivusWbApiWeb.Endpoint.broadcast!(
      "room:worker:" <> data[:id],
      "new_msg_stats",
      %{uid: 1, body: Stats.get_user_stats(2), type: "stats"}
    )

    MotivusWbApi.QueueNodes.push(MotivusWbApi.QueueNodes, data)
    # Condicionado al la correcta ejecución del push
    PubSub.broadcast(MotivusWbApi.PubSub, "matches", {"try_to_match", :hola, %{}})
    {:noreply, state}
  end

  def handle_info({"dead_node", _name, %{id: id}}, state) do
    IO.inspect(label: "dead node")
    MotivusWbApi.QueueNodes.drop(MotivusWbApi.QueueNodes, id)
    {status, task} = MotivusWbApi.QueueProcessing.drop(MotivusWbApi.QueueProcessing, id)

    case status do
      :ok ->
        PubSub.broadcast(MotivusWbApi.PubSub, "tasks", {"retry_task", :hola, task})

      _ ->
        nil
    end

    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch!(state, key), state}
  end
end

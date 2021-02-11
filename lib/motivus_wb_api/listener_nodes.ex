defmodule MotivusWbApi.ListenerNodes do
  use GenServer
  alias Phoenix.PubSub
  alias MotivusWbApi.Users
  alias MotivusWbApi.Repo
  alias MotivusWbApi.Stats

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    {:ok, {Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "nodes")}}
    |> IO.inspect(label: "Subscribed to nodes PubSub")
  end

  # Callbacks

  def handle_info({"new_channel", _, data}, state) do
    user = Repo.get_by!(Users.User, uuid: data.uuid)
    current_season = Stats.get_current_season(DateTime.utc_now())
    MotivusWbApiWeb.Endpoint.broadcast!(
      "room:worker:" <> data.uuid,
      "stats",
      %{uid: 1, body: Stats.get_user_stats(user.id, current_season), type: "stats"}
    )

    {:noreply, state}
  end

  def handle_info({"new_node", _name, data}, state) do
    IO.inspect(label: "new node")

    MotivusWbApi.QueueNodes.push(MotivusWbApi.QueueNodes, data)
    # Condicionado al la correcta ejecución del push
    PubSub.broadcast(MotivusWbApi.PubSub, "matches", {"try_to_match", :hola, %{}})
    {:noreply, state}
  end

  def handle_info({"dead_node", _name, %{id: id}}, state) do
    IO.inspect(label: "dead node")
    MotivusWbApi.QueueNodes.drop(MotivusWbApi.QueueNodes, id)
    {status, tasks} = MotivusWbApi.QueueProcessing.drop(MotivusWbApi.QueueProcessing, id)

    case status do
      :ok ->
        tasks
        |> Enum.map(fn {_tid, t} ->
          PubSub.broadcast(MotivusWbApi.PubSub, "tasks", {"retry_task", :hola, t})
        end)

      _ ->
        nil
    end

    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch!(state, key), state}
  end
end

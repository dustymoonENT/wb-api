defmodule MotivusWbApi.ListenerNodes do
  use GenServer
  alias Phoenix.PubSub
  alias MotivusWbApi.Users
  alias MotivusWbApi.Repo
  alias MotivusWbApi.Stats

  @broadcast_stats_every 15_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    {:ok, {Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "nodes")}}
    |> IO.inspect(label: "Subscribed to nodes PubSub")
  end

  # Callbacks

  def handle_info({"new_channel", _, %{channel_id: channel_id}}, state) do
    IO.inspect(label: "new channel")
    broadcast_user_stats(channel_id)
    Process.send_after(self(), {:broadcast_user_stats, channel_id}, @broadcast_stats_every)
    {:noreply, state}
  end

  def handle_info({"new_task_slot", _name, %{channel_id: channel_id} = data}, state) do
    IO.inspect(label: "new task slot")

    MotivusWbApi.QueueNodes.push(MotivusWbApi.QueueNodes, data)
    PubSub.broadcast(MotivusWbApi.PubSub, "matches", {"try_to_match", :unused, %{}})

    broadcast_user_stats(channel_id)
    {:noreply, state}
  end

  def handle_info({"dead_channel", _name, %{channel_id: channel_id}}, state) do
    IO.inspect(label: "dead channel")
    MotivusWbApi.QueueNodes.drop(MotivusWbApi.QueueNodes, channel_id)
    {status, tasks} = MotivusWbApi.QueueProcessing.drop(MotivusWbApi.QueueProcessing, channel_id)

    case status do
      :ok ->
        tasks
        |> Enum.map(fn {_tid, t} ->
          PubSub.broadcast(MotivusWbApi.PubSub, "tasks", {"retry_task", :unused, t})
        end)

      _ ->
        nil
    end

    {:noreply, state}
  end

  def handle_info({:broadcast_user_stats, channel_id}, state) do
    broadcast_user_stats(channel_id)
    Process.send_after(self(), {:broadcast_user_stats, channel_id}, @broadcast_stats_every)

    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch!(state, key), state}
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

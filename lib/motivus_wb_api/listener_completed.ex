defmodule MotivusWbApi.ListenerCompleted do
  use GenServer
  alias Phoenix.PubSub
  import Ecto.Changeset
  alias MotivusWbApi.Repo
  alias MotivusWbApi.Users
  alias MotivusWbApi.Processing.Task
  alias MotivusWbApi.Stats

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    {:ok, {Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "completed")}}
    |> IO.inspect(label: "Subscribed to completed PubSub")
  end

  # Callbacks

  def handle_info(
        {_topic, _name,
         %{
           body: body,
           type: type,
           ref: ref,
           client_id: client_id,
           id: id,
           task_id: task_id,
           tid: tid
         }},
        state
      ) do
    IO.inspect(label: "new completed")

    user = Repo.get_by!(Users.User, uuid: id)

    MotivusWbApi.QueueProcessing.drop(MotivusWbApi.QueueProcessing, id, tid)

    Repo.get_by(Task, id: task_id, user_id: user.id)
    |> change(%{date_out: DateTime.truncate(DateTime.utc_now(), :second)})
    |> Repo.update()

    MotivusWbApiWeb.Endpoint.broadcast!(
      "room:client:" <> client_id,
      "new_msg",
      %{uid: 1, body: body, type: "response", ref: ref, client_id: client_id}
    )

    MotivusWbApiWeb.Endpoint.broadcast!(
      "room:worker:" <> id,
      "stats",
      %{uid: 1, body: Stats.get_user_stats(user.id), type: "stats"}
    )

    IO.inspect(label: "DESPUES")

    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch!(state, key), state}
  end
end

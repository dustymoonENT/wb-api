defmodule MotivusWbApi.ListenerDispatch do
  use GenServer
  import Ecto.Changeset
  alias MotivusWbApi.Repo
  alias MotivusWbApi.Processing.Task
  alias MotivusWbApi.Users.User

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    {:ok, {Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "dispatch")}}
    |> IO.inspect(label: "Subscribed to dispatch PubSub")
  end

  # Callbacks

  def handle_info({_topic, _name, %{data_node: data_node, data_task: data_task}}, state) do
    IO.inspect(label: "new dispatch")

    [user_uuid, _] = data_node.channel_id |> String.split(":")

    task = Repo.get_by!(Task, id: data_task.task_id)
    user = Repo.get_by!(User, uuid: user_uuid)

    task
    |> change(%{
      date_last_dispatch: DateTime.truncate(DateTime.utc_now(), :second),
      attempts: task.attempts + 1,
      user_id: user.id
    })
    |> Repo.update()

    input = data_task |> Map.put(:tid, data_node.tid)

    MotivusWbApiWeb.Endpoint.broadcast!(
      "room:worker:" <> data_node.channel_id,
      "input",
      input
    )

    MotivusWbApi.QueueProcessing.put(
      MotivusWbApi.QueueProcessing,
      data_node.channel_id,
      data_node.tid,
      input
    )

    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch!(state, key), state}
  end
end

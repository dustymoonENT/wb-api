defmodule MotivusWbApi.Listeners.Dispatch do
  use GenServer
  import Ecto.Changeset
  alias MotivusWbApi.Repo
  alias MotivusWbApi.Processing.Task
  alias MotivusWbApi.Users.User
  import MotivusWbApi.CommonActions, only: [broadcast_user_stats: 1]

  @redact_task_data [:client_channel_id, :client_id, :task_id, :application_token_id, :ref]

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    {:ok, {Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "dispatch")}}
    |> IO.inspect(label: "Subscribed to dispatch PubSub")
  end

  # Callbacks

  def handle_info(
        {"worker_task_match", _name, %{data_node: data_node, data_task: data_task}},
        state
      ) do
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

    worker_input = data_task |> Map.put(:tid, data_node.tid) |> Map.drop(@redact_task_data)

    MotivusWbApiWeb.Endpoint.broadcast!(
      "room:worker:" <> data_node.channel_id,
      "input",
      worker_input
    )

    MotivusWbApi.ProcessingRegistry.put(
      MotivusWbApi.ProcessingRegistry,
      data_node.channel_id,
      data_node.tid,
      data_task
    )

    broadcast_user_stats(data_node.channel_id)

    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch!(state, key), state}
  end
end

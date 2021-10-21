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
        {"task_completed", _name,
         %{
           body: body,
           channel_id: channel_id,
           stdout: stdout,
           stderr: stderr,
           tid: tid
         }},
        state
      ) do
    IO.inspect(label: "new completed")
    [user_uuid, _] = channel_id |> String.split(":")

    user = Repo.get_by!(Users.User, uuid: user_uuid)

    {:ok, data_task} =
      MotivusWbApi.QueueProcessing.drop(MotivusWbApi.QueueProcessing, channel_id, tid)

    Repo.get_by(Task, id: data_task.task_id, user_id: user.id)
    |> change(%{date_out: DateTime.truncate(DateTime.utc_now(), :second), result: body})
    |> Repo.update()

    MotivusWbApiWeb.Endpoint.broadcast!(
      "room:client:" <> data_task.client_channel_id,
      "result",
      %{
        body: body,
        type: "response",
        ref: data_task.ref,
        task_id: data_task.task_id,
        stdout: stdout,
        stderr: stderr
      }
    )

    current_season = Stats.get_current_season(DateTime.utc_now())

    MotivusWbApiWeb.Endpoint.broadcast!(
      "room:worker:" <> channel_id,
      "stats",
      %{body: Stats.get_user_stats(user.id, current_season), type: "stats"}
    )

    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch!(state, key), state}
  end
end

defmodule MotivusWbApi.ListenerValidation do
  use GenServer
  alias Phoenix.PubSub
  import Ecto.Changeset
  alias MotivusWbApi.Repo
  alias MotivusWbApi.Processing.Task


  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    {:ok, {Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "validation")}}
    |> IO.inspect(label: "Subscribed to validation PubSub")
  end

  # Callbacks

  def handle_info(
        {"set_validation", _name,
         %{
           body: body,
           task_id: task_id
         }},
        state
      ) do
    IO.inspect(label: "new validation")

    Repo.get_by(Task, id: task_id)
    |> change(%{is_valid: body["is_valid"]})
    |> Repo.update()

    {:noreply, state}
  end

end

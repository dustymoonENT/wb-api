defmodule MotivusWbApi.Listeners.Validation do
  use GenServer
  import MotivusWbApi.CommonActions

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "validation")
    {:ok, nil}
  end

  def handle_info(
        {"TASK_RESULT_VALIDATED", _name,
         %{is_valid: is_valid, task_id: task_id, client_id: client_id}},
        state
      ) do
    update_task_result_validation(task_id, client_id, is_valid)

    {:noreply, state}
  end

  # TODO: invalid tasks might be automatically re-tried
end

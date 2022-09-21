defmodule MotivusWbApi.Listeners.Validation do
  @moduledoc """
  Listens for task validity events.

  A client can manifest if a task result is valid or not, this module is responsible for this interaction.
  """
  use GenServer
  import MotivusWbApi.Processing.Actions

  def start_link(context) do
    GenServer.start_link(__MODULE__, context)
  end

  def init(context) do
    Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "validation")
    {:ok, context}
  end

  def handle_info(
        {"TASK_RESULT_VALIDATED", %{is_valid: is_valid, task_id: task_id, client_id: client_id}},
        context
      ) do
    update_task_result_validation(task_id, client_id, is_valid)

    {:noreply, context}
  end

  # TODO: invalid tasks might be automatically re-tried
end

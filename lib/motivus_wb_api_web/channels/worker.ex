defmodule MotivusWbApiWeb.Channels.Worker.Result do
  @moduledoc """
  A result containing all relevant data product of a processing.
  """
  @enforce_keys [:body, :stdout, :stderr]
  defstruct @enforce_keys

  @type t :: %__MODULE__{}
end

defmodule MotivusWbApiWeb.Channels.Worker do
  @moduledoc """
  The worker's channel.

  Each worker contributing processing capabilities to the cluster is connected to a channel on which all events are communicated bidirectionally.

  Depending on the worker authentication, different PubSub channels are used to handle incoming and outgoing events. 
  Every message between the event system and the worker goes through this module, a PubSub channel is created for each worker and is the only way the other parts of the system shoud reach a worker channel.

  This module acts as a Listener to events generated internally that should end up reaching the worker, via tha handle_info/2 definitions.
  """
  use Phoenix.Channel
  alias Phoenix.PubSub
  alias MotivusWbApi.ThreadPool.Thread
  alias MotivusWbApiWeb.Channels.Worker.Result

  @doc """
  A private worker join definition.

  The private `MotivusWbApi.TaskWorkerSupervisor` stack is used for this kind of workers.
  """
  def join("room:worker:" <> channel_id, _message, %{assigns: %{scope: "private"}} = socket) do
    PubSub.subscribe(MotivusWbApi.PubSub, "node:" <> channel_id)

    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "nodes:private",
      {"WORKER_CHANNEL_OPENED", %{channel_id: channel_id}}
    )

    {:ok, socket |> assign(:channel_id, channel_id)}
  end

  @doc """
  A generic worker join definition.

  The public `MotivusWbApi.TaskWorkerSupervisor` stack is used for this kind of workers.
  """
  def join("room:worker:" <> channel_id, _message, socket) do
    PubSub.subscribe(MotivusWbApi.PubSub, "node:" <> channel_id)

    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "nodes:public",
      {"WORKER_CHANNEL_OPENED", %{channel_id: channel_id}}
    )

    {:ok, socket |> assign(:channel_id, channel_id)}
  end

  def join("room:" <> _private_room_id, _params, _socket), do: {:error, %{reason: "unauthorized"}}

  @doc """
  A new thread is available.

  A `MotivusWbApi.ThreadPool.Thread` struct is enforced.
  """
  def handle_in("input_request", %{"tid" => tid}, socket) do
    thread = struct!(Thread, %{channel_id: socket.assigns.channel_id, tid: tid})

    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "nodes:" <> socket.assigns.scope,
      {"THREAD_AVAILABLE", thread}
    )

    {:noreply, socket}
  end

  @doc """
  A new result is available.

  A `MotivusWbApiWeb.Channels.Worker.Result` struct is enforced.
  """
  def handle_in("result", %{"body" => body, "tid" => tid} = result, socket) do
    thread = struct!(Thread, %{channel_id: socket.assigns.channel_id, tid: tid})

    result =
      struct!(Result, %{
        body: body,
        stdout: result["stdout"],
        stderr: result["stderr"]
      })

    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "completed:" <> socket.assigns.scope,
      {"TASK_COMPLETED", {thread, result}}
    )

    {:noreply, socket}
  end

  @doc """
  Forward an input from the PubSub to the worker active socket.
  """
  def handle_info({"WORKER_INPUT_READY", input}, socket) do
    push(socket, "input", input)

    {:noreply, socket}
  end

  @doc """
  Signal an aborted task from the PubSub to the worker active socket.
  """
  def handle_info({"TASK_ABORTED", tid}, socket) do
    push(socket, "abort_task", %{tid: tid})

    {:noreply, socket}
  end

  @doc """
  Forward a stats summary from the PubSub to the worker active socket.
  """
  def handle_info({"WORKER_STATS_UPDATED", stats}, socket) do
    push(socket, "stats", stats)

    {:noreply, socket}
  end

  @doc """
  Signal a socket termination.
  """
  def terminate(_reason, socket) do
    PubSub.unsubscribe(MotivusWbApi.PubSub, "node:" <> socket.assigns.channel_id)

    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "nodes:" <> socket.assigns.scope,
      {"WORKER_CHANNEL_CLOSED", %{channel_id: socket.assigns.channel_id}}
    )
  end
end

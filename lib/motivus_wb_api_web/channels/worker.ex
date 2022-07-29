defmodule MotivusWbApiWeb.Channels.Worker.Result do
  @enforce_keys [:body, :stdout, :stderr]
  defstruct @enforce_keys
end

defmodule MotivusWbApiWeb.Channels.Worker do
  use Phoenix.Channel
  alias Phoenix.PubSub
  alias MotivusWbApi.ThreadPool.Thread
  alias MotivusWbApiWeb.Channels.Worker.Result

  def join("room:worker:" <> channel_id, _message, %{assigns: %{scope: "private"}} = socket) do
    PubSub.subscribe(MotivusWbApi.PubSub, "node:" <> channel_id)

    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "nodes:private",
      {"WORKER_CHANNEL_OPENED", %{channel_id: channel_id}}
    )

    {:ok, socket |> assign(:channel_id, channel_id)}
  end

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

  def handle_in("input_request", %{"tid" => tid}, socket) do
    thread = struct!(Thread, %{channel_id: socket.assigns.channel_id, tid: tid})

    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "nodes:" <> socket.assigns.scope,
      {"THREAD_AVAILABLE", thread}
    )

    {:noreply, socket}
  end

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

  def handle_info({"WORKER_INPUT_READY", input}, socket) do
    push(socket, "input", input)

    {:noreply, socket}
  end

  def handle_info({"TASK_ABORTED", tid}, socket) do
    push(socket, "abort_task", %{tid: tid})

    {:noreply, socket}
  end

  def handle_info({"WORKER_STATS_UPDATED", stats}, socket) do
    push(socket, "stats", stats)

    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    PubSub.unsubscribe(MotivusWbApi.PubSub, "node:" <> socket.assigns.channel_id)

    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "nodes:" <> socket.assigns.scope,
      {"WORKER_CHANNEL_CLOSED", %{channel_id: socket.assigns.channel_id}}
    )
  end
end

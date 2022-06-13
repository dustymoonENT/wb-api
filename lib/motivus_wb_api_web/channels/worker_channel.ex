defmodule MotivusWbApiWeb.WorkerChannel do
  use Phoenix.Channel
  alias Phoenix.PubSub
  alias MotivusWbApi.ThreadPool.Thread

  def join("room:worker:" <> channel_id, _message, socket) do
    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "nodes",
      {"WORKER_CHANNEL_OPENED", :unused, %{channel_id: channel_id}}
    )

    {:ok, socket}
  end

  def join("room:trusted_worker:" <> channel_id, _message, socket) do
    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "trusted_nodes",
      {"WORKER_CHANNEL_OPENED", :unused, %{channel_id: channel_id}}
    )

    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket), do: {:error, %{reason: "unauthorized"}}

  def handle_in("result", %{"body" => body, "tid" => tid} = result, socket) do
    [_, channel_id] = socket.topic |> String.split("room:worker:")

    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "completed",
      {"task_completed", :unused,
       %{
         body: body,
         channel_id: channel_id,
         stdout: result["stdout"],
         stderr: result["stderr"],
         tid: tid
       }}
    )

    {:noreply, socket}
  end

  def handle_in("input_request", %{"tid" => tid}, socket) do
    [_, channel_id] = socket.topic |> String.split("room:worker:")

    thread = struct!(Thread, %{channel_id: channel_id, tid: tid})

    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "nodes",
      {"THREAD_AVAILABLE", :unused, thread}
    )

    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    case socket.topic do
      "room:worker:" <> channel_id ->
        PubSub.broadcast(
          MotivusWbApi.PubSub,
          "nodes",
          {"WORKER_CHANNEL_CLOSED", :unused, %{channel_id: channel_id}}
        )

      _ ->
        nil
    end
  end
end

defmodule MotivusWbApiWeb.Channels.Worker.Result do
  @enforce_keys [:body, :stdout, :stderr]
  defstruct @enforce_keys
end

defmodule MotivusWbApiWeb.Channels.Worker do
  use Phoenix.Channel
  alias Phoenix.PubSub
  alias MotivusWbApi.ThreadPool.Thread
  alias MotivusWbApiWeb.Channels.Worker.Result

  def join("room:worker:" <> channel_id, _message, socket) do
    PubSub.broadcast(
      :public_pubsub,
      "nodes",
      {"WORKER_CHANNEL_OPENED", :unused, %{channel_id: channel_id}}
    )

    {:ok, socket}
  end

  def join("room:trusted_worker:" <> channel_id, _message, socket) do
    PubSub.broadcast(
      :private_pubsub,
      "trusted_nodes",
      {"WORKER_CHANNEL_OPENED", :unused, %{channel_id: channel_id}}
    )

    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket), do: {:error, %{reason: "unauthorized"}}

  def handle_in("result", %{"body" => body, "tid" => tid} = result, socket) do
    [_, channel_id] = socket.topic |> String.split("room:worker:")

    thread = struct!(Thread, %{channel_id: channel_id, tid: tid})

    result =
      struct!(Result, %{
        body: body,
        stdout: result["stdout"],
        stderr: result["stderr"]
      })

    PubSub.broadcast(
      :public_pubsub,
      "completed",
      {"TASK_COMPLETED", :unused, {thread, result}}
    )

    {:noreply, socket}
  end

  def handle_in("input_request", %{"tid" => tid}, socket) do
    [_, channel_id] = socket.topic |> String.split("room:worker:")

    thread = struct!(Thread, %{channel_id: channel_id, tid: tid})

    PubSub.broadcast(
      :public_pubsub,
      "nodes",
      {"THREAD_AVAILABLE", :unused, thread}
    )

    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    case socket.topic do
      "room:worker:" <> channel_id ->
        PubSub.broadcast(
          :public_pubsub,
          "nodes",
          {"WORKER_CHANNEL_CLOSED", :unused, %{channel_id: channel_id}}
        )

      _ ->
        nil
    end
  end
end

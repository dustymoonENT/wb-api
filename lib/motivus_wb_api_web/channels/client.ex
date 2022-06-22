defmodule MotivusWbApiWeb.Channels.Client do
  use Phoenix.Channel
  alias Phoenix.PubSub
  alias MotivusWbApi.TaskPool.TaskDefinition

  def join("room:client:" <> channel_id, _message, socket) do
    [user_uuid, _] = String.split(channel_id, ":")

    client_uuid = socket.assigns.user.uuid

    case user_uuid do
      ^client_uuid ->
        PubSub.subscribe(MotivusWbApi.PubSub, "client:" <> channel_id)
        {:ok, socket}

      _ ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  def join("room:client?", _params, socket) do
    {:ok, %{uuid: socket.assigns.user.uuid}, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("task", %{"body" => body, "type" => type, "ref" => ref}, socket) do
    [_, channel_id] = socket.topic |> String.split("room:client:")

    case type do
      "work" ->
        task_def =
          struct!(TaskDefinition, %{
            body: body,
            type: "work",
            ref: ref,
            client_id: socket.assigns.user.uuid,
            client_channel_id: channel_id
          })

        PubSub.broadcast(MotivusWbApi.PubSub, "tasks", {"NEW_TASK_DEFINITION", task_def})

      "trusted_work" ->
        task_def =
          struct(TaskDefinition, %{
            body: body,
            type: "work",
            ref: ref,
            client_id: socket.assigns.user.uuid,
            client_channel_id: channel_id
          })

        PubSub.broadcast(:private_pubsub, "private_tasks", {"NEW_TASK_DEFINITION", task_def})

      # MotivusWbApiWeb.Endpoint.broadcast!("room:private:api", "input", payload)

      _ ->
        nil
    end

    {:noreply, socket}
  end

  def handle_in("set_validation", %{"is_valid" => is_valid, "task_id" => task_id}, socket) do
    payload = %{is_valid: is_valid, task_id: task_id, client_id: socket.assigns.user.uuid}

    PubSub.broadcast(MotivusWbApi.PubSub, "validation", {"TASK_RESULT_VALIDATED", payload})

    {:noreply, socket}
  end

  def handle_info({"TASK_RESULT_READY", result}, socket) do
    MotivusWbApiWeb.Endpoint.broadcast!(socket.topic, "result", result)

    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    case socket.topic do
      "room:client:" <> channel_id ->
        PubSub.unsubscribe(MotivusWbApi.PubSub, "client:" <> channel_id)

        PubSub.broadcast(
          MotivusWbApi.PubSub,
          "tasks",
          {"CLIENT_CHANNEL_CLOSED", %{channel_id: channel_id}}
        )

      _ ->
        nil
    end
  end
end

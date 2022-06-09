defmodule MotivusWbApiWeb.ClientChannel do
  use Phoenix.Channel
  alias Phoenix.PubSub
  alias MotivusWbApi.TaskPool.TaskDefinition

  def join("room:client:" <> channel_id, _message, %{assigns: %{user: %{uuid: uuid}}} = socket) do
    [user_uuid, _] = String.split(channel_id, ":")

    case user_uuid do
      ^uuid -> {:ok, socket}
      _ -> {:error, %{reason: "unauthorized"}}
    end
  end

  def join("room:client?", _params, %{assigns: %{user: %{uuid: uuid}}} = socket) do
    {:ok, %{uuid: uuid}, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in(
        "task",
        %{"body" => body, "type" => type, "ref" => ref},
        %{assigns: %{user: %{uuid: uuid}}} = socket
      ) do
    [_, channel_id] = socket.topic |> String.split("room:client:")

    case type do
      "work" ->
        task_def =
          struct!(TaskDefinition, %{
            body: body,
            type: "work",
            ref: ref,
            client_id: uuid,
            client_channel_id: channel_id
          })

        PubSub.broadcast(MotivusWbApi.PubSub, "tasks", {"new_task", :unused, task_def})

      "trusted_work" ->
        task_def =
          struct(TaskDefinition, %{
            body: body,
            type: "work",
            ref: ref,
            client_id: uuid,
            client_channel_id: channel_id
          })

        PubSub.broadcast(MotivusWbApi.PubSub, "private_tasks", {"new_task", :unused, task_def})

      # MotivusWbApiWeb.Endpoint.broadcast!("room:private:api", "input", payload)

      _ ->
        nil
    end

    {:noreply, socket}
  end

  def handle_in(
        "set_validation",
        %{"body" => body, "type" => type, "task_id" => task_id},
        %{assigns: %{user: %{uuid: uuid}}} = socket
      ) do
    case type do
      "validation" ->
        payload = %{body: body, task_id: task_id, client_id: uuid}
        PubSub.broadcast(MotivusWbApi.PubSub, "validation", {"set_validation", :unused, payload})

      _ ->
        nil
    end

    {:noreply, socket}
  end

  ## agregar manejo de validated

  def terminate(_reason, socket) do
    case socket.topic do
      "room:client:" <> channel_id ->
        PubSub.broadcast(
          MotivusWbApi.PubSub,
          "tasks",
          {"dead_client", :unused, %{channel_id: channel_id}}
        )

      _ ->
        nil
    end
  end
end

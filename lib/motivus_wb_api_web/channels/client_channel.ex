defmodule MotivusWbApiWeb.ClientChannel do
  use Phoenix.Channel
  alias Phoenix.PubSub

  def join("room:client:" <> _ts, _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in(
        "new_msg",
        %{"body" => body, "type" => type, "ref" => ref, "client_id" => client_id},
        socket
      ) do
    case type do
      "work" ->
        [_, id] = socket.topic |> String.split("room:client:")
        payload = %{uid: 1, body: body, type: "work", ref: ref, client_id: id}
        PubSub.broadcast(MotivusWbApi.PubSub, "tasks", {"new_task", :hola, payload})

      _ ->
        nil
    end

    {:noreply, socket}
  end

  def terminate(reason, socket) do
    IO.inspect("desde Clientchanel")
    IO.inspect(socket.topic)
  end
end

defmodule MotivusWbApiWeb.RoomChannel do
  use Phoenix.Channel
  alias Phoenix.PubSub

  def join("room:client:" <> _ts, _message, socket) do
    {:ok, socket}
  end
  def join("room:worker:" <> _ts, _message, socket) do
    PubSub.broadcast(MotivusWbApi.PubSub, "nodes", {"new_node", :hola, %{id: _ts}})
    {:ok, socket}
  end
  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end
#  def handle_in(_, %{ref: ref, topic: "phoenix", event: "heartbeat"}, state, socket) do
#    IO.inspect("llego el heartbeat") 
#    {:noreply, socket}
#  end

  def handle_in("new_msg", %{"body" => body, "type" => type, "ref" => ref, "client_id" => client_id}, socket) do
    case type do
      "work" ->
        [_, id] = socket.topic |> String.split("room:client:")
        payload = %{uid: 1, body: body, type: "work", ref: ref, client_id: id}
        PubSub.broadcast(MotivusWbApi.PubSub, "tasks", {"new_task", :hola, payload})
      "response" ->
          [_, id] = socket.topic |> String.split("room:worker:")
          IO.inspect(respuesta: client_id)
          MotivusWbApiWeb.Endpoint.broadcast!(
            "room:client:" <> client_id, 
            "new_msg", 
            %{uid: 1, body: body, type: "response", ref: ref, client_id: client_id}
          )
          PubSub.broadcast(MotivusWbApi.PubSub, "nodes", {"new_node", :hola, %{id: id}})
      _ ->
    end
    {:noreply, socket}
  end
end

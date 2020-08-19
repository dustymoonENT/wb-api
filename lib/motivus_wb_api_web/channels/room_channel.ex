defmodule MotivusWbApiWeb.RoomChannel do
  use Phoenix.Channel
  alias Phoenix.PubSub

  def join("room:client", _message, socket) do
    {:ok, socket}
  end
  def join("room:workers", _message, socket) do
    {:ok, socket}
  end
  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end
  def handle_in("new_msg", %{"body" => body, "type" => type, "ref" => ref}, socket) do
    case type do
      "work" ->
        MotivusWbApiWeb.Endpoint.broadcast!(
          "room:workers",
          "new_msg",
          %{uid: 1, body: body, type: "work", ref: ref}
        )
      "response" ->
          MotivusWbApiWeb.Endpoint.broadcast!(
            "room:client", 
            "new_msg", 
            %{uid: 1, body: body, type: "response", ref: ref}
          )
      _ ->
    end
    {:noreply, socket}
  end
end

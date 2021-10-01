defmodule MotivusWbApiWeb.PrivateChannel do
  use Phoenix.Channel

  def join("room:private:api", _message, socket) do
    {:ok, socket}
  end

  def join("room:private:" <> _channel_id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("response", %{"body" => body, "client_channel_id" => channel_id}, socket) do
    MotivusWbApiWeb.Endpoint.broadcast!("room:client:" <> channel_id, "result", %{body: body})
    {:noreply, socket}
  end

  def terminate(_reason, _socket) do
  end
end

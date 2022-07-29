defmodule MotivusWbApiWeb.UserSocket do
  use Phoenix.Socket
  alias Guardian.Phoenix.Socket
  alias MotivusWbApi.Users.Guardian

  ## Channels
  channel "room:worker:*", MotivusWbApiWeb.Channels.Worker
  channel "room:trusted_worker:*", MotivusWbApiWeb.Channels.Worker
  channel "room:private:*", MotivusWbApiWeb.PrivateChannel
  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    with {:ok, auth_socket} <- Socket.authenticate(socket, Guardian, token),
         token_user <-
           auth_socket.assigns.guardian_default_resource do
      auth_socket =
        assign(
          auth_socket,
          :user,
          token_user
        )

      {:ok, auth_socket}
    else
      _ -> :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     MotivusWbApiWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil
end

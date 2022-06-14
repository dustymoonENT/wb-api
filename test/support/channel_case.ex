defmodule MotivusWbApiWeb.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.

  Such tests rely on `Phoenix.ChannelTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use MotivusWbApiWeb.ChannelCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      import Phoenix.ChannelTest
      import MotivusWbApiWeb.ChannelCase
      import MotivusWbApi.Fixtures
      alias MotivusWbApi.Users.Guardian

      # The default endpoint for testing
      @endpoint MotivusWbApiWeb.Endpoint

      def connect_client() do
        token = "MWBatqwerty"

        {:ok, socket} =
          MotivusWbApiWeb.ClientSocket
          |> connect(%{"token" => token}, %{})

        %{socket: socket}
      end

      def join_client_channel() do
        %{socket: socket} = connect_client()

        {:ok, %{uuid: uuid}, socket} =
          socket
          |> subscribe_and_join(MotivusWbApiWeb.Channels.Client, "room:client?")

        channel_id = "#{uuid}:#{UUID.uuid4()}"

        {:ok, _, socket} =
          socket
          |> subscribe_and_join(
            MotivusWbApiWeb.Channels.Client,
            "room:client:" <> channel_id
          )

        %{socket: socket, channel_id: channel_id}
      end

      def connect_worker() do
        user = user_fixture()
        {:ok, token, _} = Guardian.encode_and_sign(user)

        {:ok, socket} = MotivusWbApiWeb.UserSocket |> connect(%{"token" => token}, %{})
        %{socket: socket, user: user}
      end

      def join_private_worker_channel do
        %{socket: socket, user: user} = connect_worker()
        channel_id = channel_fixture(user.id)
        topic = "room:trusted_worker:#{channel_id}"

        {:ok, _, socket} =
          socket
          |> subscribe_and_join(MotivusWbApiWeb.Channels.Worker, topic)

        %{socket: socket, user: user, channel_id: channel_id, topic: topic}
      end

      def join_worker_channel do
        %{socket: socket, user: user} = connect_worker()
        channel_id = channel_fixture(user.id)
        topic = "room:worker:#{channel_id}"

        {:ok, _, socket} =
          socket
          |> subscribe_and_join(MotivusWbApiWeb.Channels.Worker, topic)

        %{socket: socket, user: user, channel_id: channel_id, topic: topic}
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MotivusWbApi.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(MotivusWbApi.Repo, {:shared, self()})
    end

    :ok
  end
end

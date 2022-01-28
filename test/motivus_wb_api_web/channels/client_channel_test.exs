defmodule MotivusWbApiWeb.ClientChannelTest do
  use MotivusWbApiWeb.ChannelCase
  import MotivusWbApi.Fixtures

  setup do
    application_token = application_token_fixture()

    {:ok, socket} =
      MotivusWbApiWeb.ClientSocket
      |> connect(%{"token" => application_token.value}, %{})

    %{socket: socket}
  end

  test "joins client channel", %{socket: socket} do
    {:ok, reply, socket} =
      socket
      |> subscribe_and_join(MotivusWbApiWeb.ClientChannel, "room:client?")

    assert %{uuid: uuid} = reply

    {:ok, _, socket} =
      socket
      |> subscribe_and_join(MotivusWbApiWeb.ClientChannel, "room:client:#{uuid}:#{UUID.uuid4()}")

    client_ref = UUID.uuid4()
    ref = push(socket, "task", %{"body" => %{}, "type" => "work", "ref" => client_ref})

    # ref = push(socket, "handleinevent", %{})
    # assert_reply ref, :ok, %{"uuid" => "there"}
  end

  test "shout broadcasts to client:lobby", %{socket: socket} do
    push(socket, "shout", %{"hello" => "all"})
    assert_broadcast "shout", %{"hello" => "all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end

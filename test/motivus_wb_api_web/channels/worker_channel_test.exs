defmodule MotivusWbApiWeb.WorkerChannelTest do
  use MotivusWbApiWeb.ChannelCase
  import MotivusWbApi.Fixtures
  alias MotivusWbApi.Users.Guardian

  defp create_socket_and_log_user() do
    user = user_fixture()
    {:ok, token, _} = Guardian.encode_and_sign(user)

    {:ok, socket} = MotivusWbApiWeb.UserSocket |> connect(%{"token" => token}, %{})
    %{socket: socket, user: user}
  end

  setup do
    MotivusWbApi.QueueTasks.empty()
    MotivusWbApi.QueueNodes.empty()
    MotivusWbApi.QueueProcessing.empty()

    create_socket_and_log_user()
  end

  test "worker can join and offer computing resource", %{socket: socket, user: user} do
    channel_id = channel_fixture(user.id)

    {:ok, _, socket} =
      socket
      |> subscribe_and_join(MotivusWbApiWeb.WorkerChannel, "room:worker:#{channel_id}")

    assert_push "stats", _stats
    slot_1 = UUID.uuid4()
    slot_2 = UUID.uuid4()

    push(socket, "input_request", %{"tid" => slot_1})
    push(socket, "input_request", %{"tid" => slot_2})

    refute_broadcast "*", _payload

    %{socket: socket, user: user} = create_socket_and_log_user()
    other_channel_id = channel_fixture(user.id)

    {:ok, _, socket} =
      socket
      |> subscribe_and_join(MotivusWbApiWeb.WorkerChannel, "room:worker:#{other_channel_id}")

    assert_broadcast "stats", _stats

    slot_3 = UUID.uuid4()

    push(socket, "input_request", %{"tid" => slot_3})

    refute_broadcast "*", _payload

    nodes = MotivusWbApi.QueueNodes.list()

    initial_tid =
      [slot_1, slot_2]
      |> Enum.map(fn tid -> %{channel_id: channel_id, tid: tid} end)

    other_tid =
      [slot_3]
      |> Enum.map(fn tid -> %{channel_id: other_channel_id, tid: tid} end)

    assert nodes == initial_tid ++ other_tid
  end
end

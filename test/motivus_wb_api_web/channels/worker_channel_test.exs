defmodule MotivusWbApiWeb.WorkerChannelTest do
  use MotivusWbApiWeb.ChannelCase
  alias MotivusWbApi.QueueStructs.Thread
  import Mock

  setup_with_mocks([
    {Mojito, [],
     [
       request: fn
         _opts ->
           {:ok,
            %Mojito.Response{
              body:
                "{\"data\":{\"avatar_url\":\"https://avatars.githubusercontent.com/u/13546914?v=4\",\"email\":\"f.mora.g90@gmail.com\",\"id\":2,\"name\":\"a8c71\",\"provider\":\"github\",\"username\":null,\"uuid\":\"3b796d2f-4d75-4b71-a55c-9137296a6574\"}}",
              status_code: 200
            }}
       end
     ]}
  ]) do
    MotivusWbApi.QueueTasks.empty()
    MotivusWbApi.QueueNodes.empty()
    MotivusWbApi.QueueProcessing.empty()

    join_worker_channel()
  end

  test "worker can join and offer computing resource", %{socket: socket, channel_id: channel_id} do
    assert_push "stats", %{
      body: %{
        threads_available: 0,
        threads_processing: 0,
        tasks_available: 0,
        tasks_processing: 0
      }
    }

    assert MotivusWbApi.get_worker_users_total() == 0

    slot_1 = UUID.uuid4()
    slot_2 = UUID.uuid4()

    push(socket, "input_request", %{"tid" => slot_1})
    push(socket, "input_request", %{"tid" => slot_2})

    assert_push "stats", %{
      body: %{
        threads_available: 2,
        threads_processing: 0,
        tasks_available: 0,
        tasks_processing: 0
      }
    }

    assert MotivusWbApi.get_worker_users_total() == 1

    %{channel_id: other_channel_id, socket: socket} = join_worker_channel()

    assert_push "stats", %{
      body: %{
        threads_available: 2,
        threads_processing: 0,
        tasks_available: 0,
        tasks_processing: 0
      }
    }

    slot_3 = UUID.uuid4()

    push(socket, "input_request", %{"tid" => slot_3})

    refute_broadcast "*", _payload

    assert MotivusWbApi.get_worker_users_total() == 2

    assert_push "stats", %{
      body: %{
        threads_available: 3,
        threads_processing: 0,
        tasks_available: 0,
        tasks_processing: 0
      }
    }

    nodes = MotivusWbApi.QueueNodes.list()

    initial_tid =
      [slot_1, slot_2]
      |> Enum.map(fn tid -> struct(Thread, %{channel_id: channel_id, tid: tid}) end)

    other_tid =
      [slot_3]
      |> Enum.map(fn tid -> struct(Thread, %{channel_id: other_channel_id, tid: tid}) end)

    assert nodes == initial_tid ++ other_tid

    %{socket: client_socket} = join_client_channel()

    push(client_socket, "task", %{body: %{}, type: "work", ref: UUID.uuid4()})

    refute_broadcast "*", _payload

    assert_push "stats", %{
      body: %{
        threads_available: 2,
        threads_processing: 1,
        tasks_available: 0,
        tasks_processing: 1
      }
    }

    push(client_socket, "task", %{body: %{}, type: "work", ref: UUID.uuid4()})
    push(client_socket, "task", %{body: %{}, type: "work", ref: UUID.uuid4()})
    push(client_socket, "task", %{body: %{}, type: "work", ref: UUID.uuid4()})

    refute_broadcast "*", _payload

    assert_push "stats", %{
      body: %{
        threads_available: 0,
        threads_processing: 3,
        tasks_available: 1,
        tasks_processing: 3
      }
    }

    assert MotivusWbApi.get_worker_users_total() == 2

    Process.unlink(client_socket.channel_pid)
    close(client_socket)
    assert_push "abort_task", _
  end
end

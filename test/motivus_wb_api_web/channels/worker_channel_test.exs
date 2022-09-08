defmodule MotivusWbApiWeb.WorkerChannelTest do
  use MotivusWbApiWeb.ChannelCase
  alias MotivusWbApi.ThreadPool.Thread
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
    MotivusWbApi.TaskPool.empty(:public_task_pool)
    MotivusWbApi.ThreadPool.empty(:public_thread_pool)
    MotivusWbApi.ProcessingRegistry.empty(:public_processing_registry)

    join_worker_channel()
  end

  test "worker can join and offer computing resource", %{
    socket: socket,
    channel_id: channel_id,
    user: %{id: user_id}
  } do
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

    %{channel_id: other_channel_id, socket: other_worker_socket} = join_worker_channel()

    assert_push "stats", %{
      body: %{
        threads_available: 2,
        threads_processing: 0,
        tasks_available: 0,
        tasks_processing: 0
      }
    }

    slot_3 = UUID.uuid4()

    push(other_worker_socket, "input_request", %{"tid" => slot_3})

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

    threads = MotivusWbApi.ThreadPool.list(:public_thread_pool)

    initial_tid =
      [slot_1, slot_2]
      |> Enum.map(fn tid -> struct(Thread, %{channel_id: channel_id, tid: tid}) end)

    other_tid =
      [slot_3]
      |> Enum.map(fn tid -> struct(Thread, %{channel_id: other_channel_id, tid: tid}) end)

    assert threads == initial_tid ++ other_tid

    %{socket: client_socket} = join_client_channel()

    push(client_socket, "task", %{body: %{}, type: "work", ref: UUID.uuid4()})

    refute_broadcast "*", _payload

    [db_task] = MotivusWbApi.Processing.list_tasks()

    assert %{attempts: 1, user_id: ^user_id, result: nil, security_level: "PUBLIC"} = db_task

    assert_push "stats", %{
      body: %{
        threads_available: 2,
        threads_processing: 1,
        tasks_available: 0,
        tasks_processing: 1
      }
    }

    assert_push("input", %{body: %{}})

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

    push(socket, "result", %{body: %{}, tid: slot_1})

    refute_broadcast "*", _payload

    db_task = MotivusWbApi.Processing.get_task!(db_task.id)
    # assert %{attempts: 1, user_id: ^user_id, result: %{}} = db_task
    assert %{attempts: 1, user_id: ^user_id, result: nil} = db_task

    push(client_socket, "set_validation", %{
      "is_valid" => true,
      "task_id" => db_task.id
    })

    refute_broadcast "*", _payload

    db_task = MotivusWbApi.Processing.get_task!(db_task.id)
    assert %{is_valid: true} = db_task

    Process.unlink(client_socket.channel_pid)
    close(client_socket)
    assert_push "abort_task", _

    refute_broadcast "*", _payload
  end
end

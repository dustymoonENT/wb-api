defmodule MotivusWbApiWeb.PrivateWorkerChannelTest do
  use MotivusWbApiWeb.ChannelCase
  alias MotivusWbApi.Processing
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
    MotivusWbApi.TaskPool.empty(:private_task_pool)
    MotivusWbApi.ThreadPool.empty(:private_thread_pool)
    MotivusWbApi.ProcessingRegistry.empty(:private_processing_registry)

    join_private_worker_channel()
  end

  test "task is registered for trusted_work", %{socket: socket, channel_id: _channel_id} do
    push(socket, "input_request", %{"tid" => UUID.uuid4()})
    refute_broadcast "*", _payload

    assert MotivusWbApi.ThreadPool.list(:private_thread_pool) |> length() == 1

    %{socket: client_socket} = join_client_channel()

    push(client_socket, "task", %{body: %{}, type: "trusted_work", ref: UUID.uuid4()})
    refute_broadcast "*", _payload

    [task] = Processing.list_tasks()
    assert %{security_level: "SECURE"} = task
  end
end

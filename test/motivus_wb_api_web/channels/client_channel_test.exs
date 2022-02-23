defmodule MotivusWbApiWeb.ClientChannelTest do
  use MotivusWbApiWeb.ChannelCase
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

    connect_client()
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
    task = %{body: %{}, type: "work", ref: client_ref}
    push(socket, "task", task)

    refute_broadcast "*", _

    assert [%{ref: ^client_ref, client_id: ^uuid}] = MotivusWbApi.QueueTasks.list()
  end
end

defmodule MotivusWbApi.QueueNodesTest do
  use MotivusWbApi.DataCase
  alias MotivusWbApi.QueueNodes
  import MotivusWbApi.Fixtures

  test "queue actions" do
    user = user_fixture()
    worker_slot_1 = worker_slot_fixture(user.id)
    worker_slot_2 = worker_slot_fixture(user.id)
    {:noreply, state} = QueueNodes.handle_cast({:push, worker_slot_1}, [])
    {:noreply, state} = QueueNodes.handle_cast({:push, worker_slot_2}, state)
    assert state == [worker_slot_1, worker_slot_2]

    assert {:reply, ^worker_slot_1, [^worker_slot_2] = state} =
             QueueNodes.handle_call(:pop, :nowhere, state)

    assert {:noreply, [^worker_slot_1, ^worker_slot_2] = state} =
             QueueNodes.handle_cast({:push_top, worker_slot_1}, state)
  end
end

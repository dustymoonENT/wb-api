# defmodule MotivusWbApi.ThreadPoolTest do
#   use MotivusWbApi.DataCase
#   alias MotivusWbApi.ThreadPool
#   import MotivusWbApi.Fixtures

#   test "queue actions" do
#     user = user_fixture()
#     worker_slot_1 = worker_slot_fixture(user.id)
#     worker_slot_2 = worker_slot_fixture(user.id)
#     {:noreply, state} = ThreadPool.handle_cast({:push, worker_slot_1}, [])
#     {:noreply, state} = ThreadPool.handle_cast({:push, worker_slot_2}, state)
#     assert state == [worker_slot_1, worker_slot_2]

#     assert {:reply, ^worker_slot_1, [^worker_slot_2] = state} =
#              ThreadPool.handle_call(:pop, :nowhere, state)

#     assert {:noreply, [^worker_slot_1, ^worker_slot_2] = state} =
#              ThreadPool.handle_cast({:push_top, worker_slot_1}, state)
#   end
# end

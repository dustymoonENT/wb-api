defmodule MotivusWbApi.QueueNodesTest do
  use MotivusWbApi.DataCase
  alias MotivusWbApi.QueueNodes
  import MotivusWbApi.Fixtures

  test "queue actions" do
    user = user_fixture()
    worker_channel_1 = worker_channel_fixture(user.id)
    worker_channel_2 = worker_channel_fixture(user.id)
    {:noreply, state} = QueueNodes.handle_cast({:push, worker_channel_1}, [])
    {:noreply, state} = QueueNodes.handle_cast({:push, worker_channel_2}, state)
    assert state == [worker_channel_1, worker_channel_2]

    assert {:reply, ^worker_channel_1, [^worker_channel_2] = state} =
             QueueNodes.handle_call(:pop, :nowhere, state)

    assert {:noreply, [^worker_channel_1, ^worker_channel_2] = state} =
             QueueNodes.handle_cast({:push_top, worker_channel_1}, state)
  end

  #   test "upgrade works even when we are already premium" do
  #     {:noreply, state} = Weather.handle_cast(:upgrade, %Weather.State{url: :premium})
  #     assert state.url == :premium
  #   end

  #   # etc, etc, etc...
  #   # Probably something similar here for downgrade

  #   test "weather_in using regular" do
  #     state = %Weather.State{url: :regular}
  #     {:reply, response, newstate} = Weather.handle_call({:weather_in, "dallas", "US"}, nil, state)
  #     # we aren't expecting changes
  #     assert newstate == state
  #     assert response == "sunny and hot"
  #   end

  #   test "weather_in using premium" do
  #     state = %Weather.State{url: :premium}
  #     {:reply, response, newstate} = Weather.handle_call({:weather_in, "dallas", "US"}, nil, state)
  #     # we aren't expecting changes
  #     assert newstate == state
  #     assert response == "95F, 30% humidity, sunny and hot"
  #   end

  #   # etc, etc, etc...      
end

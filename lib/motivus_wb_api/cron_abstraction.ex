defmodule MotivusWbApi.CronAbstraction do
  use GenServer
  alias MotivusWbApi.Stats

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: args[:id])
  end

  def init(state) do
    # Schedule work to be performed on start
    schedule_work(state)
    {:ok, state}
  end

  def handle_info(:ranking, args) do
    # Do the desired work here
    Stats.set_ranking(DateTime.utc_now())
    schedule_work(args)
    {:noreply, args}
  end

  defp schedule_work(args) do
    Process.send_after(self(), args[:work], args[:loop_time])
  end
end

defmodule MotivusWbApi.QueueNodes do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def push(pid, element) do
    GenServer.cast(pid, {:push, element})
  end

  def push_top(pid, element) do
    GenServer.cast(pid, {:push_top, element})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  # Callbacks

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_call(:pop, _from, elements) do
    try do
      [head | tail] = elements
      {:reply, head, tail}
    rescue
      MatchError -> {:reply, :error, []}
    end
  end

  @impl true
  def handle_cast({:push, element}, state) do
    case length(state) do
          0 -> 
            {:noreply, [element]}
          _ -> 
            {:noreply, state ++ [element]}
        end
  end

  @impl true
  def handle_cast({:push_top, element}, state) do
    case length(state) do
          0 -> 
            {:noreply, [element]}
          _ -> 
            {:noreply, [element] ++ state}
        end
  end
end

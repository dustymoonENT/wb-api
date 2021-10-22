defmodule MotivusWbApi.QueueTasks do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def push(pid, element) do
    GenServer.cast(pid, {:push, element})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  def list(pid) do
    GenServer.call(pid, :list)
  end

  def drop(pid, client_channel_id) do
    GenServer.call(pid, {:drop_by, :client_channel_id, client_channel_id})
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
  def handle_call({:drop_by, key, value}, _from, elements) do
    partition = elements |> Enum.group_by(fn e -> e |> Map.get(key) == value end)
    {:reply, Map.get(partition, true, []), Map.get(partition, false, [])}
  end

  @impl true
  def handle_call(:list, _from, elements) do
    {:reply, elements, elements}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end
end

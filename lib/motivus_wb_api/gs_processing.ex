defmodule MotivusWbApi.QueueProcessing do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def put(pid, channel_id, tid, task) do
    GenServer.cast(pid, {:put, channel_id, tid, task})
  end

  @doc """
  Drops all processing tasks associated to the channel_id supplied
  """
  def drop(pid, channel_id) do
    GenServer.call(pid, {:drop, channel_id})
  end

  @doc """
  Drops a single processing task by channel_id and thread id
  """
  def drop(pid, channel_id, tid) do
    GenServer.call(pid, {:drop, channel_id, tid})
  end

  def list(pid) do
    GenServer.call(pid, :list)
  end

  # Callbacks

  @impl true
  def init(map \\ %{}) do
    {:ok, map}
  end

  @impl true
  def handle_call(:list, _from, map) do
    flat_map =
      map |> Enum.map(fn {_node_id, threads} -> threads end) |> Enum.flat_map(fn t -> t end)

    {:reply, flat_map, map}
  end

  @impl true
  def handle_cast({:put, node_id, tid, task}, map) do
    tasks = Map.get(map, node_id) || %{}
    new_value = Map.put(tasks, tid, task)
    {:noreply, Map.put(map, node_id, new_value)}
  end

  @impl true
  def handle_call({:drop, key}, _from, map) do
    case Map.has_key?(map, key) do
      true -> {:reply, Map.fetch(map, key), Map.drop(map, [key])}
      false -> {:reply, {:error, "No key"}, map}
    end
  end

  @impl true
  def handle_call({:drop, key, tid}, _from, map) do
    tasks = Map.get(map, key) || %{}
    task = Map.fetch(tasks, tid)
    new_tasks = Map.drop(tasks, [tid])

    case Map.has_key?(tasks, tid) do
      true -> {:reply, task, Map.put(map, key, new_tasks)}
      false -> {:reply, {:error, "No key"}, map}
    end
  end
end

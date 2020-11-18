defmodule MotivusWbApi.QueueProcessing do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def put(pid, node_id, task) do
    GenServer.cast(pid, {:put, node_id, task})
  end

  def drop(pid, id) do
    GenServer.call(pid,{:drop,id})
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
    {:reply, Map.keys(map), map}
  end

  @impl true
  def handle_cast({:put, node_id, task}, map) do
    {:noreply, Map.put(map, node_id, task)} 
  end

  @impl true
  def handle_call({:drop, key}, _from, map) do
    case Map.has_key?(map, key) do
      true -> {:reply, Map.fetch(map, key), Map.drop(map, [key])}
      false -> {:reply, {:error, "No key"}, map}
    end
  end
end

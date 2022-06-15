defmodule MotivusWbApi.TaskPool.TaskDefinition do
  @enforce_keys [:body, :type, :ref, :client_id, :client_channel_id]
  defstruct @enforce_keys
end

defmodule MotivusWbApi.TaskPool.Task do
  @enforce_keys [:body, :type, :ref, :client_id, :client_channel_id, :task_id]
  defstruct @enforce_keys
end

defmodule MotivusWbApi.TaskPool do
  use GenServer
  alias MotivusWbApi.TaskPool.Task

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def push(pid, %Task{} = task) do
    GenServer.cast(pid, {:push, task})
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

  def empty(pid) do
    GenServer.call(pid, :clear)
  end

  # Callbacks

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_call(:pop, _from, tasks) do
    try do
      [head | tail] = tasks
      {:reply, head, tail}
    rescue
      MatchError -> {:reply, :error, []}
    end
  end

  @impl true
  def handle_call({:drop_by, key, value}, _from, tasks) do
    partition = tasks |> Enum.group_by(fn e -> e |> Map.get(key) == value end)
    {:reply, Map.get(partition, true, []), Map.get(partition, false, [])}
  end

  @impl true
  def handle_call(:list, _from, tasks) do
    {:reply, tasks, tasks}
  end

  @impl true
  def handle_call(:clear, _from, _tasks) do
    {:reply, [], []}
  end

  @impl true
  def handle_cast({:push, %Task{} = task}, tasks) do
    {:noreply, [task | tasks]}
  end
end

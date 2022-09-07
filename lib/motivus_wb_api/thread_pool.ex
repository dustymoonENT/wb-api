defmodule MotivusWbApi.ThreadPool.Thread do
  @enforce_keys [:channel_id, :tid]
  defstruct @enforce_keys

  def format(%__MODULE__{} = thread) do
    thread.channel_id <> ":" <> thread.tid
  end
end

defmodule MotivusWbApi.ThreadPool do
  use GenServer
  alias MotivusWbApi.ThreadPool.Thread

  import MotivusWbApi.Metrics.WorkerTaskInstrumenter, only: [update_metric_task: 1]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def push(pid, %Thread{} = thread) do
    GenServer.cast(pid, {:push, thread})
  end

  def push_top(pid, %Thread{} = thread) do
    GenServer.cast(pid, {:push_top, thread})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  def drop(pid, target)

  @doc """
  Drops a single thread belonging to a channel
  """
  def drop(pid, %Thread{} = thread) do
    GenServer.cast(pid, {:drop, thread.channel_id, thread.tid})
  end

  @doc """
  Drops all threads belonging to a channel
  """
  def drop(pid, channel_id) do
    GenServer.cast(pid, {:drop, channel_id})
  end

  def list(pid) do
    GenServer.call(pid, :list)
  end

  def empty(pid) do
    GenServer.call(pid, :clear)
  end

  def by_user(pid) do
    GenServer.call(pid, :by_user)
  end

  # Callbacks

  @impl true
  def init(stack) do
    update_metric_task(stack |> length)
    {:ok, stack}
  end

  @impl true
  def handle_call(:pop, _from, threads) do
    try do
      [head | tail] = threads
      update_metric_task(tail |> length)
      {:reply, head, tail}
    rescue
      MatchError -> {:reply, :error, []}
    end
  end

  @impl true
  def handle_call(:list, _from, threads) do
    {:reply, threads, threads}
  end

  @impl true
  def handle_call(:clear, _from, _threads) do
    update_metric_task(0)
    {:reply, [], []}
  end

  @impl true
  def handle_call(:by_user, _from, threads) do
    map =
      threads
      |> Enum.group_by(fn %{channel_id: channel_id} ->
        [user_uuid | _] = channel_id |> String.split(":")
        user_uuid
      end)

    {:reply, map, threads}
  end

  @impl true
  def handle_cast({:push, thread}, threads) do
    case length(threads) do
      0 ->
        update_metric_task(1)
        {:noreply, [thread]}

      l ->
        update_metric_task(l + 1)
        {:noreply, threads ++ [thread]}
    end
  end

  @impl true
  def handle_cast({:push_top, thread}, threads) do
    case length(threads) do
      0 ->
        update_metric_task(1)
        {:noreply, [thread]}

      l ->
        update_metric_task(l + 1)
        {:noreply, [thread] ++ threads}
    end
  end

  @impl true
  def handle_cast({:drop, id}, threads) do
    threads = Enum.reject(threads, fn t -> t.channel_id == id end)
    update_metric_task(threads |> length)

    {:noreply, threads}
  end

  @impl true
  def handle_cast({:drop, channel_id, tid}, threads) do
    threads = Enum.reject(threads, fn t -> t.channel_id == channel_id and t.tid == tid end)
    update_metric_task(threads |> length)
    {:noreply, threads}
  end
end

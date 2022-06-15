defmodule MotivusWbApi.ThreadPool.Thread do
  @enforce_keys [:channel_id, :tid]
  defstruct @enforce_keys
end

defmodule MotivusWbApi.ThreadPool do
  use GenServer
  alias MotivusWbApi.ThreadPool.Thread

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
    {:ok, stack}
  end

  @impl true
  def handle_call(:pop, _from, threads) do
    try do
      [head | tail] = threads
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
        {:noreply, [thread]}

      _ ->
        {:noreply, threads ++ [thread]}
    end
  end

  @impl true
  def handle_cast({:push_top, thread}, threads) do
    case length(threads) do
      0 ->
        {:noreply, [thread]}

      _ ->
        {:noreply, [thread] ++ threads}
    end
  end

  @impl true
  def handle_cast({:drop, id}, threads) do
    {:noreply, Enum.reject(threads, fn t -> t.channel_id == id end)}
  end

  @impl true
  def handle_cast({:drop, channel_id, tid}, threads) do
    {:noreply, Enum.reject(threads, fn t -> t.channel_id == channel_id and t.tid == tid end)}
  end
end

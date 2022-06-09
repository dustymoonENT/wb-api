defmodule MotivusWbApi.QueueStructs.Thread do
  @enforce_keys [:channel_id, :tid]
  defstruct [:channel_id, :tid]
end

defmodule MotivusWbApi.QueueNodes do
  use GenServer
  alias MotivusWbApi.QueueStructs.Thread

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def push(pid \\ __MODULE__, %Thread{} = element) do
    GenServer.cast(pid, {:push, element})
  end

  def push_top(pid \\ __MODULE__, %Thread{} = element) do
    GenServer.cast(pid, {:push_top, element})
  end

  def pop(pid \\ __MODULE__) do
    GenServer.call(pid, :pop)
  end

  def drop(pid \\ __MODULE__, target)

  @doc """
  Drops a single thread belonging to a channel
  """
  def drop(pid, %Thread{} = element) do
    GenServer.cast(pid, {:drop, element.channel_id, element.tid})
  end

  @doc """
  Drops all threads belonging to a channel
  """
  def drop(pid, channel_id) do
    GenServer.cast(pid, {:drop, channel_id})
  end

  def list(pid \\ __MODULE__) do
    GenServer.call(pid, :list)
  end

  def empty(pid \\ __MODULE__) do
    GenServer.call(pid, :clear)
  end

  def by_user(pid \\ __MODULE__) do
    GenServer.call(pid, :by_user)
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
  def handle_call(:list, _from, elements) do
    {:reply, elements, elements}
  end

  @impl true
  def handle_call(:clear, _from, _elements) do
    {:reply, [], []}
  end

  @impl true
  def handle_call(:by_user, _from, elements) do
    map =
      elements
      |> Enum.group_by(fn %{channel_id: channel_id} ->
        [user_uuid | _] = channel_id |> String.split(":")
        user_uuid
      end)

    {:reply, map, elements}
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

  @impl true
  def handle_cast({:drop, id}, state) do
    {:noreply, Enum.filter(state, fn e -> e.channel_id != id end)}
  end

  @impl true
  def handle_cast({:drop, channel_id, tid}, state) do
    element = %{channel_id: channel_id, tid: tid}
    {:noreply, state -- [element]}
  end
end

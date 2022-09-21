defmodule MotivusWbApi.TaskWorkerSupervisor do
  @moduledoc """
  Supervisor for isolated processing instances.

  Using ie. "public" and "private" instances allows to operate two separate processing queues and listeners.
  """
  use Supervisor

  def start_link(scope) do
    id = (scope <> "_stack_supervisor") |> String.to_atom()
    Supervisor.start_link(__MODULE__, scope, name: id)
  end

  @impl true
  def init(scope) do
    children = task_worker_stack(scope)

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Defines supervisor children for pools, registries and listeners
  """
  @spec task_worker_stack(String.t()) :: [Supervisor.child_spec()]
  def task_worker_stack(id) do
    task_pool = String.to_atom(id <> "_task_pool")
    thread_pool = String.to_atom(id <> "_thread_pool")
    processing_registry = String.to_atom(id <> "_processing_registry")
    tasks_listener = String.to_atom(id <> "_tasks_listener")
    nodes_listener = String.to_atom(id <> "_nodes_listener")
    match_listener = String.to_atom(id <> "_match_listener")
    dispatch_listener = String.to_atom(id <> "_dispatch_listener")
    completed_listener = String.to_atom(id <> "_completed_listener")

    [
      Supervisor.child_spec({MotivusWbApi.TaskPool, name: task_pool},
        id: task_pool
      ),
      Supervisor.child_spec(
        {MotivusWbApi.ThreadPool, name: thread_pool},
        id: thread_pool
      ),
      Supervisor.child_spec(
        {MotivusWbApi.ProcessingRegistry, name: processing_registry},
        id: processing_registry
      ),
      Supervisor.child_spec(
        {MotivusWbApi.Listeners.Task,
         %{
           name: MotivusWbApi.Listeners.Task,
           scope: id,
           task_pool: %{module: MotivusWbApi.TaskPool, id: task_pool},
           processing_registry: %{
             module: MotivusWbApi.ProcessingRegistry,
             id: processing_registry
           }
         }},
        id: tasks_listener
      ),
      Supervisor.child_spec(
        {MotivusWbApi.Listeners.Node,
         %{
           name: MotivusWbApi.Listeners.Node,
           scope: id,
           thread_pool: %{module: MotivusWbApi.ThreadPool, id: thread_pool},
           processing_registry: %{
             module: MotivusWbApi.ProcessingRegistry,
             id: processing_registry
           }
         }},
        id: nodes_listener
      ),
      Supervisor.child_spec(
        {MotivusWbApi.Listeners.Match,
         %{
           name: MotivusWbApi.Listeners.Match,
           scope: id,
           thread_pool: %{module: MotivusWbApi.ThreadPool, id: thread_pool},
           task_pool: %{module: MotivusWbApi.TaskPool, id: task_pool}
         }},
        id: match_listener
      ),
      Supervisor.child_spec(
        {MotivusWbApi.Listeners.Dispatch,
         %{
           name: MotivusWbApi.Listeners.Dispatch,
           scope: id,
           processing_registry: %{
             module: MotivusWbApi.ProcessingRegistry,
             id: processing_registry
           }
         }},
        id: dispatch_listener
      ),
      Supervisor.child_spec(
        {MotivusWbApi.Listeners.Completed,
         %{
           name: MotivusWbApi.Listeners.Completed,
           scope: id,
           processing_registry: %{
             module: MotivusWbApi.ProcessingRegistry,
             id: processing_registry
           }
         }},
        id: completed_listener
      )
    ]
  end
end

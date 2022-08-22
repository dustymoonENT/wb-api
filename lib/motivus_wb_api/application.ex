defmodule MotivusWbApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Telemetry.Metrics

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

  def start(_type, _args) do
    Confex.resolve_env!(:motivus_wb_api)
    MotivusWbApi.MetricsExporter.setup()
    MotivusWbApi.Metrics.TasksQueueInstrumenter.setup()

    children =
      [
        # Start the Ecto repository
        MotivusWbApi.Repo,
        {Phoenix.PubSub, name: MotivusWbApi.PubSub},
        # Start the Endpoint (http/https)
        MotivusWbApiWeb.Endpoint,
        # Start a worker by calling: MotivusWbApi.Worker.start_link(arg)
        Supervisor.child_spec({MotivusWbApi.CronAbstraction, cron_config_1_ranking()},
          id: cron_config_1_ranking()[:id]
        ),
        {TelemetryMetricsCloudwatch,
         [metrics: metrics(), push_interval: 10_000, namespace: "motivus_wb_api_#{Mix.env()}"]},
        # Start the Telemetry supervisor
        MotivusWbApiWeb.Telemetry
      ] ++
        task_worker_stack("public") ++
        task_worker_stack("private") ++
        [
          Supervisor.child_spec(
            {MotivusWbApi.Listeners.Validation, %{name: MotivusWbApi.Listeners.Validation}},
            id: :listener_validation
          )
        ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MotivusWbApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MotivusWbApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp cron_config_1_ranking do
    %{
      app_id: 1,
      worker: :worker_cron_1_ranking,
      work: :ranking,
      loop_time: 600_000,
      id: :cron_1_ranking
    }
  end

  defp metrics do
    [
      Metrics.last_value("nodes.queue.total"),
      Metrics.last_value("tasks.queue.total"),
      Metrics.last_value("processing.queue.total"),
      Metrics.last_value("worker.users.total")
    ]
  end
end

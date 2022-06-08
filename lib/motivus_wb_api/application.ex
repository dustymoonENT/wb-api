defmodule MotivusWbApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Telemetry.Metrics

  def start(_type, _args) do
    Confex.resolve_env!(:motivus_wb_api)

    children = [
      # Start the Ecto repository
      MotivusWbApi.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: MotivusWbApi.PubSub},
      # Start the Endpoint (http/https)
      MotivusWbApiWeb.Endpoint,
      # Start a worker by calling: MotivusWbApi.Worker.start_link(arg)
      # {MotivusWbApi.Worker, arg}
      # Queue for Tasks
      Supervisor.child_spec({MotivusWbApi.QueueTasks, name: MotivusWbApi.QueueTasks},
        id: :queue_tasks
      ),
      # Queue for Nodes
      Supervisor.child_spec({MotivusWbApi.QueueNodes, name: MotivusWbApi.QueueNodes},
        id: :queue_nodes
      ),
      # Queue for Processing task
      Supervisor.child_spec({MotivusWbApi.QueueProcessing, name: MotivusWbApi.QueueProcessing},
        id: :queue_processing
      ),
      # Pubsub
      # {Phoenix.PubSub, name: :my_pubsub},
      # Listener
      Supervisor.child_spec(
        {MotivusWbApi.ListenerTasks,
         name: MotivusWbApi.ListenerTasks,
         queue_tasks: MotivusWbApi.QueueTasks,
         queue_processing: MotivusWbApi.QueueProcessing},
        id: :listener_tasks
      ),
      Supervisor.child_spec({MotivusWbApi.ListenerNodes, name: MotivusWbApi.ListenerNodes},
        id: :listener_nodes
      ),
      Supervisor.child_spec({MotivusWbApi.ListenerMatches, name: MotivusWbApi.ListenerMatches},
        id: :listener_matches
      ),
      Supervisor.child_spec({MotivusWbApi.ListenerDispatch, name: MotivusWbApi.ListenerDispatch},
        id: :listener_dispatch
      ),
      Supervisor.child_spec(
        {MotivusWbApi.ListenerCompleted, name: MotivusWbApi.ListenerCompleted},
        id: :listener_completed
      ),
      Supervisor.child_spec(
        {MotivusWbApi.ListenerValidation, name: MotivusWbApi.ListenerValidation},
        id: :listener_validation
      ),
      Supervisor.child_spec({MotivusWbApi.CronAbstraction, cron_config_1_ranking()},
        id: cron_config_1_ranking()[:id]
      ),
      {TelemetryMetricsCloudwatch,
       [metrics: metrics(), push_interval: 10_000, namespace: "motivus_wb_api_#{Mix.env()}"]},
      # {TelemetryMetricsPrometheus, [metrics: metrics()]},
      # Start the Telemetry supervisor
      MotivusWbApiWeb.Telemetry
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

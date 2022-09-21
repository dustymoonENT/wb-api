defmodule MotivusWbApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    Confex.resolve_env!(:motivus_wb_api)
    MotivusWbApi.Metrics.WorkerTaskInstrumenter.setup()
    MotivusWbApi.Metrics.PhoenixInstrumenter.setup()
    MotivusWbApi.Metrics.PipelineInstrumenter.setup()
    MotivusWbApi.Metrics.RepoInstrumenter.setup()
    MotivusWbApi.PrometheusExporter.setup()

    :ok =
      :telemetry.attach(
        "prometheus-ecto",
        [:motivus_wb_api, :repo, :query],
        &MotivusWbApi.Metrics.RepoInstrumenter.handle_event/4,
        %{}
      )

    children = [
      # Start the Ecto repository
      MotivusWbApi.Repo,
      {Phoenix.PubSub, name: MotivusWbApi.PubSub},
      # Start the Endpoint (http/https)
      MotivusWbApiWeb.Endpoint,
      # Start a worker by calling: MotivusWbApi.Worker.start_link(arg)
      Supervisor.child_spec({MotivusWbApi.CronAbstraction, cron_config_1_ranking()},
        id: cron_config_1_ranking()[:id]
      ),
      # Start the Telemetry supervisor
      MotivusWbApiWeb.Telemetry,
      Supervisor.child_spec({MotivusWbApi.TaskWorkerSupervisor, "public"},
        id: :public_stack,
        type: :supervisor
      ),
      Supervisor.child_spec({MotivusWbApi.TaskWorkerSupervisor, "private"},
        id: :private_stack,
        type: :supervisor
      ),
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

  # defp metrics do
  #   [
  #     Metrics.last_value("nodes.queue.total"),
  #     Metrics.last_value("tasks.queue.total"),
  #     Metrics.last_value("processing.queue.total"),
  #     Metrics.last_value("worker.users.total")
  #   ]
  # end
end

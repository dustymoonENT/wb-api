defmodule MotivusWbApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      MotivusWbApi.Repo,
      # Start the Telemetry supervisor
      MotivusWbApiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MotivusWbApi.PubSub},
      # Start the Endpoint (http/https)
      MotivusWbApiWeb.Endpoint,
      # Start a worker by calling: MotivusWbApi.Worker.start_link(arg)
      # {MotivusWbApi.Worker, arg}
      # Queue for Tasks
      Supervisor.child_spec({MotivusWbApi.QueueTasks, name: MotivusWbApi.QueueTasks}, id: :queue_tasks),
      # Queue for Nodes
      Supervisor.child_spec({MotivusWbApi.QueueNodes, name: MotivusWbApi.QueueNodes}, id: :queue_nodes),
	  # Queue for Processing task
      Supervisor.child_spec({MotivusWbApi.QueueProcessing, name: MotivusWbApi.QueueProcessing}, id: :queue_processing),
      # Pubsub
      #{Phoenix.PubSub, name: :my_pubsub},
      # Listener
      Supervisor.child_spec({MotivusWbApi.ListenerTasks, name: 
      MotivusWbApi.ListenerTasks}, id: :listener_tasks),
      Supervisor.child_spec({MotivusWbApi.ListenerNodes, name:
      MotivusWbApi.ListenerNodes}, id: :listener_nodes),
      Supervisor.child_spec({MotivusWbApi.ListenerMatches, name:
      MotivusWbApi.ListenerMatches}, id: :listener_matches),
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
end

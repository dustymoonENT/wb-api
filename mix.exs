defmodule MotivusWbApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :motivus_wb_api,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),

      # Docs
      name: "Motivus Engine",
      source_url: "https://github.com/m0tivus/motivus-wb-api",
      homepage_url: "https://motivus.cl",
      docs: [
        # The main page in the docs
        main: "MotivusWbApi.TaskWorkerSupervisor"
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MotivusWbApi.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :ueberauth,
        :ueberauth_github,
        :ueberauth_google,
        :ueberauth_facebook,
        :confex,
        :retry,
        :prometheus_plugs,
        :prometheus_ex,
        :prometheus_phoenix,
        :prometheus_ecto,
        :os_mon
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.4"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.2"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:cors_plug, "~> 2.0"},
      {:guardian, "~> 2.0"},
      {:guardian_phoenix, "~> 2.0"},
      {:ueberauth_github, "~> 0.7"},
      {:ueberauth_google, "~> 0.10"},
      {:ueberauth_facebook, "~> 0.8"},
      {:confex, "~> 3.5.0"},
      {:mojito, "~> 0.7.10"},
      {:mock, "~> 0.3.0", only: :test},
      {:uuid, "~> 1.1"},
      {:retry, "~> 0.15"},
      {:prometheus_ex, "~> 3.0.5"},
      {:prometheus_plugs, "~> 1.1.1"},
      {:prometheus_phoenix, "~> 1.3.0"},
      {:prometheus_ecto, "~> 1.4.3"},
      {:dialyxir, "~> 1.1.0", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "0.27.3", only: :dev, runtime: false},
      {:phoenix_live_view, "~> 0.15"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.seed": ["run priv/repo/seeds.exs"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seed"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end

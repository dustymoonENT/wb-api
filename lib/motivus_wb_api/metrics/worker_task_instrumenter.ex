defmodule MotivusWbApi.Metrics.WorkerTaskInstrumenter do
  use Prometheus.Metric

  def setup() do
    Gauge.declare(
      name: :private_task_pool,
      help: "Total tasks pending in private pool"
    )

    Gauge.declare(
      name: :private_thread_pool,
      help: "Total workers available in private pool"
    )

    Gauge.declare(
      name: :private_processing_registry,
      help: "Total tasks being processed in private registry"
    )

    Gauge.declare(
      name: :public_task_pool,
      help: "Total tasks pending in public pool"
    )

    Gauge.declare(
      name: :public_thread_pool,
      help: "Total workers available in public pool"
    )

    Gauge.declare(
      name: :public_processing_registry,
      help: "Total tasks being processed in public registry"
    )
  end

  @spec set_size(atom(), non_neg_integer() | list()) :: no_return()
  def set_size(name, value) when is_integer(value) do
    Gauge.set([name: name], value)
  end

  def set_size(name, value) when is_list(value), do: set_size(name, value |> length)

  @spec update_metric_task(non_neg_integer() | list()) :: {:ok, pid()}
  def update_metric_task(value),
    do:
      Task.start(__MODULE__, :set_size, [
        Process.info(self())
        |> Keyword.get(:registered_name),
        value
      ])
end

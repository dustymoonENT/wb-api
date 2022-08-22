defmodule MotivusWbApi.Metrics.TasksQueueInstrumenter do
  use Prometheus.Metric
  def setup() do
    Gauge.declare(
      name: :tasks_total,
      help: "Total tasks in queue"
    )
  end 
  def set_size(size) do
    Gauge.set(
      [name: :tasks_total],
      size
    )
  end
end

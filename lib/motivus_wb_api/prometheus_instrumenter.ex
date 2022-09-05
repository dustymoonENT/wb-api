defmodule MotivusWbApi.Metrics.TasksQueueInstrumenter do
  use Prometheus.Metric
  alias MotivusWbApi.TaskPool

  def setup() do
    Gauge.declare([
      name: :private_tasks_total,
      help: "Total tasks in private queue"
    ])

    Gauge.declare([
      name: :public_tasks_total,
      help: "Total tasks in public queue"
    ])
  end 

  def set_size(_pid) do
    private = length(TaskPool.list(:private_task_pool))
    public = length(TaskPool.list(:public_task_pool))
    Gauge.set(
      [name: :private_tasks_total],
      private
    )
    Gauge.set(
      [name: :public_tasks_total],
      public
    )

  end
end

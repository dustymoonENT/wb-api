defmodule MotivusWbApi do
  alias MotivusWbApi.QueueNodes
  alias MotivusWbApi.QueueTasks
  alias MotivusWbApi.QueueProcessing

  @moduledoc """
  MotivusWbApi keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def nodes_queue_total do
    # :telemetry.execute([:nodes, :queue], %{total: length(QueueNodes.list(QueueNodes))}, %{})
    total = length(QueueNodes.list(QueueNodes))
    :telemetry.execute([:nodes, :queue], %{total: total}, %{})
  end

  def tasks_queue_total do
    # :telemetry.execute([:nodes, :queue], %{total: length(QueueNodes.list(QueueNodes))}, %{})
    total = length(QueueTasks.list(QueueTasks))
    :telemetry.execute([:tasks, :queue], %{total: total}, %{})
  end

  def processing_queue_total do
    # :telemetry.execute([:nodes, :queue], %{total: length(QueueNodes.list(QueueNodes))}, %{})
    total = length(QueueProcessing.list(QueueProcessing))
    :telemetry.execute([:processing, :queue], %{total: total}, %{})
  end
end

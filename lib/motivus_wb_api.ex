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
    total = length(QueueNodes.list(QueueNodes))
    :telemetry.execute([:nodes, :queue], %{total: total}, %{})
  end

  def tasks_queue_total do
    total = length(QueueTasks.list(QueueTasks))
    :telemetry.execute([:tasks, :queue], %{total: total}, %{})
  end

  def processing_queue_total do
    total = length(QueueProcessing.list(QueueProcessing))
    :telemetry.execute([:processing, :queue], %{total: total}, %{})
  end

  def worker_users_total do
    :telemetry.execute([:worker, :users], %{total: get_worker_users_total()}, %{})
  end

  def get_worker_users_total() do
    (Map.keys(QueueProcessing.by_worker_user()) ++
       Map.keys(QueueNodes.by_user()))
    |> Enum.uniq()
    |> length()
  end
end

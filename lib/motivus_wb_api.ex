defmodule MotivusWbApi do
  alias MotivusWbApi.ThreadPool
  alias MotivusWbApi.TaskPool
  alias MotivusWbApi.ProcessingRegistry

  @moduledoc """
  MotivusWbApi keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def nodes_queue_total do
    total = length(ThreadPool.list(:private_thread_pool))
    :telemetry.execute([:nodes, :queue], %{total: total}, %{})
  end

  def tasks_queue_total do
    total = length(TaskPool.list(:private_task_pool))
    :telemetry.execute([:tasks, :queue], %{total: total}, %{})
  end

  def processing_queue_total do
    total = length(ProcessingRegistry.list(:private_processing_registry))
    :telemetry.execute([:processing, :queue], %{total: total}, %{})
  end

  def worker_users_total do
    :telemetry.execute([:worker, :users], %{total: get_worker_users_total(:private)}, %{})
  end

  def get_worker_users_total(:private) do
    (Map.keys(ProcessingRegistry.by_worker_user(:private_processing_registry)) ++
       Map.keys(ThreadPool.by_user(:private_thread_pool)))
    |> Enum.uniq()
    |> length()
  end

  def get_worker_users_total() do
    (Map.keys(ProcessingRegistry.by_worker_user(:public_processing_registry)) ++
       Map.keys(ThreadPool.by_user(:public_thread_pool)))
    |> Enum.uniq()
    |> length()
  end
end

defmodule MotivusWbApi.Stats do
  @moduledoc """
  The Processing context.
  """

  import Ecto.Query, warn: false
  alias MotivusWbApi.Repo

  alias MotivusWbApi.Processing.Task
  alias MotivusWbApi.Users.User
  alias MotivusWbApi.CurrentSeasonRanking
  alias MotivusWbApi.Ranking.Season

  def get_user_stats(user_id) do
    user = Repo.get_by(User, id: user_id)
    query = from t in Task, where: not is_nil(t.date_out) and t.user_id == ^user_id
    user_tasks = Repo.all(query)
    quantity = Enum.count(user_tasks)
    user_base_time = Enum.reduce(user_tasks, 0, fn x, acc -> x.processing_base_time + acc end)
    user_flops = Enum.reduce(user_tasks, 0, fn x, acc -> x.flops + acc end)

    user_elapsed_time =
      Enum.reduce(
        user_tasks,
        0,
        fn x, acc ->
          DateTime.diff(x.date_out, x.date_last_dispatch) + acc
        end
      )

    payload = %{
      quantity: quantity,
      base_time: user_base_time,
      flops: user_flops,
      elapsed_time: user_elapsed_time,
      ranking: user.ranking
    }

    payload
  end

  def set_users_ranking() do
    query = """
      WITH asd AS 
    (SELECT user_id, sum(flops) as flops FROM "tasks" group by user_id),
    r AS
    (SELECT user_id as id, flops, RANK() OVER (ORDER BY flops desc) as rank from asd)
    update users
    set ranking = rank
    FROM r
    where users.id = r.id
    """

    Ecto.Adapters.SQL.query!(MotivusWbApi.Repo, query, [])
  end

  def get_current_season(current_timestamp) do
    query = from s in Season, where: ^current_timestamp > s.start_date and ^current_timestamp < s.end_date
    season = Repo.one(query)
    season
  end

  def set_ranking(current_timestamp) do
    Repo.delete_all(CurrentSeasonRanking)
    current_season = get_current_season(current_timestamp)

    query = """
    WITH total_tasks AS
    (SELECT user_id, count(id) AS total_tasks, SUM(date_out - date_last_dispatch) AS elapsed_time FROM tasks group by user_id),
    ranking_tasks AS
    (SELECT user_id, total_tasks, elapsed_time, RANK() OVER(ORDER BY total_tasks DESC) AS total_tasks_rank,
    RANK() OVER(ORDER BY elapsed_time DESC) AS elapsed_time_rank FROM total_tasks)
    INSERT INTO current_season_ranking(processing_ranking, elapsed_time_ranking, user_id, seasons, inserted_at, updated_at)
    SELECT total_tasks_rank, elapsed_time_rank, user_id, #{current_season}, current_timestamp, current_timestamp
    FROM ranking_tasks
    """

    Ecto.Adapters.SQL.query!(MotivusWbApi.Repo, query, [])



  end

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Repo.all(Task)
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end
end

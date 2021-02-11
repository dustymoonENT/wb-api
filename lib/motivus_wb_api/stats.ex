defmodule MotivusWbApi.Stats do
  @moduledoc """
  The Processing context.
  """

  import Ecto.Query, warn: false
  alias MotivusWbApi.Repo

  alias MotivusWbApi.Processing.Task
  alias MotivusWbApi.Users.User
  alias MotivusWbApi.Ranking.CurrentSeasonRanking
  alias MotivusWbApi.Ranking.Season

  def get_user_stats(user_id, current_season) do
    user = Repo.get_by(User, id: user_id)
    ranking = from c in CurrentSeasonRanking, where: c.user_id == ^user_id
    user_ranking = Repo.one(ranking)

    season_stats = {current_season, user_ranking}

    case season_stats do
      {nil, nil} ->
        %{
          task_quantity: nil,
          base_time: nil,
          elapsed_time: nil,
          elapsed_time_ranking: nil,
          processing_ranking: nil,
          flop: nil,
          season: %{
            name: nil,
            start_date: nil,
            end_date: nil
          }
        }

      {_cs, ur} ->
        query =
          from t in Task,
            where:
              not is_nil(t.date_out) and t.user_id == ^user_id and
                t.date_out > ^current_season.start_date and t.date_out < ^current_season.end_date and
                t.is_valid == true

        user_tasks = Repo.all(query)
        quantity = Enum.count(user_tasks)
        user_base_time = Enum.reduce(user_tasks, 0, fn x, acc -> x.processing_base_time + acc end)
        flop = Enum.reduce(user_tasks, 0, fn x, acc -> x.flop + acc end)

        user_elapsed_time =
          Enum.reduce(
            user_tasks,
            0,
            fn x, acc ->
              DateTime.diff(x.date_out, x.date_last_dispatch) + acc
            end
          )

        %{
          task_quantity: quantity,
          base_time: user_base_time,
          elapsed_time: user_elapsed_time,
          elapsed_time_ranking: ur && user_ranking.elapsed_time_ranking,
          processing_ranking: ur && user_ranking.processing_ranking,
          flop: flop,
          season: %{
            name: current_season.name,
            start_date: current_season.start_date,
            end_date: current_season.end_date
          }
        }
    end
  end

  def get_current_season(current_timestamp) do
    query =
      from s in Season,
        where: ^current_timestamp > s.start_date and ^current_timestamp < s.end_date

    season = Repo.one(query)
    season
  end

  def set_ranking(current_timestamp) do
    Repo.delete_all(CurrentSeasonRanking)
    current_season = get_current_season(current_timestamp)

    if current_season do
      query = """
      WITH total_flop AS
      (SELECT user_id, SUM(flop) AS total_flop, SUM(date_out - date_last_dispatch) AS elapsed_time
      FROM tasks 
      INNER JOIN users u ON u.id = user_id AND NOT u.black_listed 
      WHERE date_out > $1 AND date_out < $2 AND is_valid
      GROUP BY user_id),
      ranking_tasks AS
      (SELECT user_id, total_flop, elapsed_time, RANK() OVER(ORDER BY total_flop DESC) AS total_flop_rank,
      RANK() OVER(ORDER BY elapsed_time DESC) AS elapsed_time_rank FROM total_flop)
      INSERT INTO current_season_ranking(processing_ranking, elapsed_time_ranking, user_id, seasons, inserted_at, updated_at)
      SELECT total_flop_rank, elapsed_time_rank, user_id, #{current_season.id}, current_timestamp, current_timestamp
      FROM ranking_tasks
      """

      Ecto.Adapters.SQL.query!(MotivusWbApi.Repo, query, [
        current_season.start_date,
        current_season.end_date
      ])
    end
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

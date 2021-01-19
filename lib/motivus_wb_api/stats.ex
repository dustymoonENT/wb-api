defmodule MotivusWbApi.Stats do
  @moduledoc """
  The Processing context.
  """

  import Ecto.Query, warn: false
  alias MotivusWbApi.Repo

  alias MotivusWbApi.Processing.Task
  alias MotivusWbApi.Users.User

  def get_user_stats(user_id) do
    user = Repo.get_by(User, id: user_id)
    query = from t in Task, where: not is_nil(t.date_out) and t.user_id == ^user_id
    user_tasks = Repo.all(query)
    quantity = Enum.count(user_tasks)
    user_base_time = Enum.reduce(user_tasks, 0, fn x, acc -> x.processing_base_time + acc end)
    user_flops = Enum.reduce(user_tasks, 0, fn x, acc -> x.flops + acc end)

    user_elapsed_time =
      Enum.reduce(user_tasks, 0, fn x, acc ->
        DateTime.diff(x.date_out, x.date_last_dispatch) + acc
      end)

    payload = %{
      quantity: quantity,
      base_time: user_base_time,
      flops: user_flops,
      elapsed_time: user_elapsed_time,
      ranking: user.ranking
    }

    IO.inspect(payload)
    payload
  end

  def get_users_ranking() do
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

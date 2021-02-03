defmodule MotivusWbApi.Ranking do
  @moduledoc """
  The Ranking context.
  """

  import Ecto.Query, warn: false
  alias MotivusWbApi.Repo

  alias MotivusWbApi.Ranking.Season

  @doc """
  Returns the list of seasons.

  ## Examples

      iex> list_seasons()
      [%Season{}, ...]

  """
  def list_seasons do
    Repo.all(Season)
  end

  @doc """
  Gets a single season.

  Raises `Ecto.NoResultsError` if the Season does not exist.

  ## Examples

      iex> get_season!(123)
      %Season{}

      iex> get_season!(456)
      ** (Ecto.NoResultsError)

  """
  def get_season!(id), do: Repo.get!(Season, id)

  @doc """
  Creates a season.

  ## Examples

      iex> create_season(%{field: value})
      {:ok, %Season{}}

      iex> create_season(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_season(attrs \\ %{}) do
    %Season{}
    |> Season.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a season.

  ## Examples

      iex> update_season(season, %{field: new_value})
      {:ok, %Season{}}

      iex> update_season(season, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_season(%Season{} = season, attrs) do
    season
    |> Season.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a season.

  ## Examples

      iex> delete_season(season)
      {:ok, %Season{}}

      iex> delete_season(season)
      {:error, %Ecto.Changeset{}}

  """
  def delete_season(%Season{} = season) do
    Repo.delete(season)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking season changes.

  ## Examples

      iex> change_season(season)
      %Ecto.Changeset{data: %Season{}}

  """
  def change_season(%Season{} = season, attrs \\ %{}) do
    Season.changeset(season, attrs)
  end

  alias MotivusWbApi.Ranking.CurrentSeasonRanking

  @doc """
  Returns the list of current_season_ranking.

  ## Examples

      iex> list_current_season_ranking()
      [%CurrentSeasonRanking{}, ...]

  """
  def list_current_season_ranking do
    Repo.all(CurrentSeasonRanking)
  end

  @doc """
  Gets a single current_season_ranking.

  Raises `Ecto.NoResultsError` if the Current season ranking does not exist.

  ## Examples

      iex> get_current_season_ranking!(123)
      %CurrentSeasonRanking{}

      iex> get_current_season_ranking!(456)
      ** (Ecto.NoResultsError)

  """
  def get_current_season_ranking!(id), do: Repo.get!(CurrentSeasonRanking, id)

  @doc """
  Creates a current_season_ranking.

  ## Examples

      iex> create_current_season_ranking(%{field: value})
      {:ok, %CurrentSeasonRanking{}}

      iex> create_current_season_ranking(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_current_season_ranking(attrs \\ %{}) do
    %CurrentSeasonRanking{}
    |> CurrentSeasonRanking.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a current_season_ranking.

  ## Examples

      iex> update_current_season_ranking(current_season_ranking, %{field: new_value})
      {:ok, %CurrentSeasonRanking{}}

      iex> update_current_season_ranking(current_season_ranking, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_current_season_ranking(%CurrentSeasonRanking{} = current_season_ranking, attrs) do
    current_season_ranking
    |> CurrentSeasonRanking.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a current_season_ranking.

  ## Examples

      iex> delete_current_season_ranking(current_season_ranking)
      {:ok, %CurrentSeasonRanking{}}

      iex> delete_current_season_ranking(current_season_ranking)
      {:error, %Ecto.Changeset{}}

  """
  def delete_current_season_ranking(%CurrentSeasonRanking{} = current_season_ranking) do
    Repo.delete(current_season_ranking)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking current_season_ranking changes.

  ## Examples

      iex> change_current_season_ranking(current_season_ranking)
      %Ecto.Changeset{data: %CurrentSeasonRanking{}}

  """
  def change_current_season_ranking(%CurrentSeasonRanking{} = current_season_ranking, attrs \\ %{}) do
    CurrentSeasonRanking.changeset(current_season_ranking, attrs)
  end
end

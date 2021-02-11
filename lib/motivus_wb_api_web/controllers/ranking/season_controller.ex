defmodule MotivusWbApiWeb.Ranking.SeasonController do
  use MotivusWbApiWeb, :controller

  alias MotivusWbApi.Ranking
  alias MotivusWbApi.Ranking.Season

  action_fallback MotivusWbApiWeb.FallbackController

  def index(conn, _params) do
    seasons = Ranking.list_seasons()
    render(conn, "index.json", seasons: seasons)
  end

  def create(conn, %{"season" => season_params}) do
    with {:ok, %Season{} = season} <- Ranking.create_season(season_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.season_path(conn, :show, season))
      |> render("show.json", season: season)
    end
  end

  def show(conn, %{"id" => id}) do
    season = Ranking.get_season!(id)
    render(conn, "show.json", season: season)
  end

  def update(conn, %{"id" => id, "season" => season_params}) do
    season = Ranking.get_season!(id)

    with {:ok, %Season{} = season} <- Ranking.update_season(season, season_params) do
      render(conn, "show.json", season: season)
    end
  end

  def delete(conn, %{"id" => id}) do
    season = Ranking.get_season!(id)

    with {:ok, %Season{}} <- Ranking.delete_season(season) do
      send_resp(conn, :no_content, "")
    end
  end
end

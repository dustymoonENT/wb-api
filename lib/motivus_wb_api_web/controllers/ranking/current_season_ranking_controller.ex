defmodule MotivusWbApiWeb.Ranking.CurrentSeasonRankingController do
  use MotivusWbApiWeb, :controller

  alias MotivusWbApi.Ranking
  alias MotivusWbApi.Ranking.CurrentSeasonRanking

  action_fallback MotivusWbApiWeb.FallbackController

  def index(conn, _params) do
    current_season_ranking = Ranking.list_current_season_ranking()
    render(conn, "index.json", current_season_ranking: current_season_ranking)
  end

  def create(conn, %{"current_season_ranking" => current_season_ranking_params}) do
    with {:ok, %CurrentSeasonRanking{} = current_season_ranking} <- Ranking.create_current_season_ranking(current_season_ranking_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.current_season_ranking_path(conn, :show, current_season_ranking))
      |> render("show.json", current_season_ranking: current_season_ranking)
    end
  end

  def show(conn, %{"id" => id}) do
    current_season_ranking = Ranking.get_current_season_ranking!(id)
    render(conn, "show.json", current_season_ranking: current_season_ranking)
  end

  def update(conn, %{"id" => id, "current_season_ranking" => current_season_ranking_params}) do
    current_season_ranking = Ranking.get_current_season_ranking!(id)

    with {:ok, %CurrentSeasonRanking{} = current_season_ranking} <- Ranking.update_current_season_ranking(current_season_ranking, current_season_ranking_params) do
      render(conn, "show.json", current_season_ranking: current_season_ranking)
    end
  end

  def delete(conn, %{"id" => id}) do
    current_season_ranking = Ranking.get_current_season_ranking!(id)

    with {:ok, %CurrentSeasonRanking{}} <- Ranking.delete_current_season_ranking(current_season_ranking) do
      send_resp(conn, :no_content, "")
    end
  end
end

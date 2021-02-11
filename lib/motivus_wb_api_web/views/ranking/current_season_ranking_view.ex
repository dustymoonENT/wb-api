defmodule MotivusWbApiWeb.Ranking.CurrentSeasonRankingView do
  use MotivusWbApiWeb, :view
  alias MotivusWbApiWeb.Ranking.CurrentSeasonRankingView

  def render("index.json", %{current_season_ranking: current_season_ranking}) do
    %{data: render_many(current_season_ranking, CurrentSeasonRankingView, "current_season_ranking.json")}
  end

  def render("show.json", %{current_season_ranking: current_season_ranking}) do
    %{data: render_one(current_season_ranking, CurrentSeasonRankingView, "current_season_ranking.json")}
  end

  def render("current_season_ranking.json", %{current_season_ranking: current_season_ranking}) do
    %{id: current_season_ranking.id,
      processing_ranking: current_season_ranking.processing_ranking,
      elapsed_time_ranking: current_season_ranking.elapsed_time_ranking}
  end
end

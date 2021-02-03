defmodule MotivusWbApiWeb.Ranking.SeasonView do
  use MotivusWbApiWeb, :view
  alias MotivusWbApiWeb.Ranking.SeasonView

  def render("index.json", %{seasons: seasons}) do
    %{data: render_many(seasons, SeasonView, "season.json")}
  end

  def render("show.json", %{season: season}) do
    %{data: render_one(season, SeasonView, "season.json")}
  end

  def render("season.json", %{season: season}) do
    %{id: season.id,
      start_date: season.start_date,
      end_date: season.end_date,
      name: season.name}
  end
end

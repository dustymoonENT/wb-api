defmodule MotivusWbApi.Ranking.CurrentSeasonRanking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "current_season_ranking" do
    field :elapsed_time_ranking, :integer
    field :processing_ranking, :integer
    field :user_id, :id
    field :seasons, :id

    timestamps()
  end

  @doc false
  def changeset(current_season_ranking, attrs) do
    current_season_ranking
    |> cast(attrs, [:processing_ranking, :elapsed_time_ranking])
    |> validate_required([:processing_ranking, :elapsed_time_ranking])
  end
end

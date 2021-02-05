defmodule MotivusWbApi.Ranking.Season do
  use Ecto.Schema
  import Ecto.Changeset

  schema "seasons" do
    field :end_date, :utc_datetime
    field :name, :string
    field :start_date, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(season, attrs) do
    season
    |> cast(attrs, [:start_date, :end_date, :name])
    |> validate_required([:start_date, :end_date, :name])
  end
end

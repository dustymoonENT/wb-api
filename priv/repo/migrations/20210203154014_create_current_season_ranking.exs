defmodule MotivusWbApi.Repo.Migrations.CreateCurrentSeasonRanking do
  use Ecto.Migration

  def change do
    create table(:current_season_ranking) do
      add :processing_ranking, :integer
      add :elapsed_time_ranking, :integer
      add :user_id, references(:users, on_delete: :nothing)
      add :seasons, references(:seasons, on_delete: :nothing)

      timestamps()
    end

    create index(:current_season_ranking, [:user_id])
    create index(:current_season_ranking, [:seasons])
  end
end

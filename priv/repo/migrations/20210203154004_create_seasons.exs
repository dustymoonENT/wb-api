defmodule MotivusWbApi.Repo.Migrations.CreateSeasons do
  use Ecto.Migration

  def change do
    create table(:seasons) do
      add :start_date, :utc_datetime
      add :end_date, :utc_datetime
      add :name, :string

      timestamps()
    end

  end
end

defmodule MotivusWbApi.Repo.Migrations.AddBlacklistedToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :black_listed, :boolean, default: false
    end
  end
end

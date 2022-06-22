defmodule MotivusWbApi.Repo.Migrations.AddSecurityLevelToTask do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :security_level, :string, null: true
    end
  end
end

defmodule MotivusWbApi.Repo.Migrations.CreateApplicationTokens do
  use Ecto.Migration

  def change do
    create table(:application_tokens) do
      add :description, :string
      add :value, :string
      add :valid, :boolean
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:application_tokens, [:user_id])
  end
end

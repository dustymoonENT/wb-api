defmodule MotivusWbApi.Repo.Migrations.AddApplicationTokenIdToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :application_token_id, references(:application_tokens, on_delete: :nothing)
    end
  end
end

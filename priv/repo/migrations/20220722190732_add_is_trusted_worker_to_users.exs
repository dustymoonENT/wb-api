defmodule MotivusWbApi.Repo.Migrations.AddIsTrustedWorkerToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_trusted_worker, :boolean, default: false
    end
  end
end

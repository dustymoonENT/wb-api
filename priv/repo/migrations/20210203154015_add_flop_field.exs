defmodule MotivusWbApi.Repo.Migrations.AddFlopField do
  use Ecto.Migration
  def change do
    alter table(:tasks) do
      add :flop, :float
      add :result, :map
      add :is_valid, :boolean
      add :client_id, :string
    end
  end
end
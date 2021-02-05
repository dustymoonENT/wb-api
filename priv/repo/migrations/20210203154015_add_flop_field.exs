defmodule MotivusWbApi.Repo.Migrations.AddFlopField do
  use Ecto.Migration
  def change do
    alter table(:tasks) do
      add :flop, :float
    end
  end
end
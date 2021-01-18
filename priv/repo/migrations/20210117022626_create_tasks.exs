defmodule MotivusWbApi.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :type, :string
      add :params, :map
      add :date_in, :utc_datetime
      add :date_last_dispatch, :utc_datetime
      add :date_out, :utc_datetime
      add :attempts, :integer, default: 0
      add :flops, :float
      add :processing_base_time, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:tasks, [:user_id])
  end
end

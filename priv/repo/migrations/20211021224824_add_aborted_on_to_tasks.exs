defmodule MotivusWbApi.Repo.Migrations.AddAbortedOnToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :aborted_on, :utc_datetime
    end
  end
end

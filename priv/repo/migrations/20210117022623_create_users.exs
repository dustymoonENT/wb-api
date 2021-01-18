defmodule MotivusWbApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :mail, :string
      add :avatar, :string
      add :provider, :string
      add :uuid, :uuid
      add :is_guest, :boolean, default: false, null: false
      add :last_sign_in, :utc_datetime

      timestamps()
    end

  end
end

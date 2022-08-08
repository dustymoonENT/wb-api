defmodule MotivusWbApi.Repo.Migrations.AddEmailUniqueConstraintToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :mail, :string, nullable: true, from: :string
    end

    create unique_index(:users, [:mail], where: "mail IS NOT NULL")
  end
end

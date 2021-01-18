defmodule MotivusWbApi.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :avatar, :string
    field :is_guest, :boolean, default: false
    field :last_sign_in, :utc_datetime
    field :mail, :string
    field :name, :string
    field :provider, :string
    field :uuid, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :mail, :avatar, :provider, :uuid, :is_guest, :last_sign_in])
    |> validate_required([:name, :mail, :avatar, :provider, :uuid, :is_guest, :last_sign_in])
  end
end
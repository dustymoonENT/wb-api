defmodule MotivusWbApi.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :avatar, :provider, :mail, :uuid]}
  schema "users" do
    field :avatar, :string
    field :is_guest, :boolean, default: false
    field :last_sign_in, :utc_datetime
    field :mail, :string
    field :name, :string
    field :provider, :string
    field :uuid, Ecto.UUID
    field :ranking, :integer
    field :black_listed, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :name,
      :mail,
      :avatar,
      :provider,
      :uuid,
      :is_guest,
      :last_sign_in,
      :black_listed
    ])
    |> validate_required([:name, :mail, :uuid, :is_guest])
  end

  def external_provider_changeset(user, attrs) do
    types = %{
      avatar_url: :string,
      email: :string,
      id: :integer,
      name: :string,
      provider: :string,
      username: :string,
      uuid: :string
    }

    {%{} = user, types}
    |> cast(attrs, Map.keys(types))
    |> validate_required([:uuid, :id, :email])
  end
end

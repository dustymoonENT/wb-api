defmodule MotivusWbApi.Users.ApplicationToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "application_tokens" do
    field :description, :string
    field :value, :string
    field :user_id, :id
    field :valid, :boolean, default: true, null: false

    timestamps()
  end

  @doc false
  def changeset(application_token, attrs) do
    application_token
    |> cast(attrs, [:description, :value, :user_id, :valid])
    |> validate_required([:description, :value, :user_id, :valid])
  end

  @doc false
  def update_changeset(application_token, attrs) do
    application_token
    |> cast(attrs, [:description, :valid])
  end
end

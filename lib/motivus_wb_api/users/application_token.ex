defmodule MotivusWbApi.Users.ApplicationToken do
  @deprecated "Application Tokens are moved now to Marketplace implementation"
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
    |> cast(attrs, [:description, :user_id, :valid])
    |> generate_value()
    |> validate_required([:description, :value, :user_id, :valid])
    |> unique_constraint(:value)
  end

  @doc false
  def update_changeset(application_token, attrs) do
    application_token
    |> cast(attrs, [:description, :valid])
  end

  defp generate_value(chset) do
    {:changes, user_id} = fetch_field(chset, :user_id)

    random =
      Ecto.UUID.autogenerate()
      |> Plug.Crypto.KeyGenerator.generate("#{user_id}", iterations: 65536)
      |> Base.url_encode64()

    put_change(chset, :value, "MWBat#{random}")
  end
end

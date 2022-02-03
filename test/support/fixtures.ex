defmodule MotivusWbApi.Fixtures do
  @moduledoc false

  alias MotivusWbApi.Users
  alias MotivusWbApi.Processing

  def fixture(:user) do
    with {:ok, user} <-
           Users.create_user(%{
             avatar: "some avatar",
             is_guest: true,
             last_sign_in: "2010-04-17T14:00:00Z",
             mail: "some mail",
             name: "some name",
             provider: "some provider",
             uuid: UUID.uuid4()
           }) do
      user
    end
  end

  def user_fixture(_attrs \\ %{}), do: fixture(:user)

  def fixture(:application_token, user_id) do
    {:ok, application_token} =
      Users.create_application_token(
        %{
          description: "some description",
          value: "some value",
          valid: true
        }
        |> Map.put(:user_id, user_id)
      )

    application_token
  end

  def application_token_fixture(attrs \\ %{}) do
    user =
      case attrs do
        %{user_id: user_id} -> Users.get_user!(user_id)
        _ -> fixture(:user)
      end

    {:ok, application_token} =
      attrs
      |> Enum.into(%{description: "some description", user_id: user.id})
      |> Users.create_application_token()

    application_token
  end

  def task_fixture(attrs \\ %{}) do
    user =
      case attrs do
        %{user_id: user_id} -> Users.get_user!(user_id)
        _ -> fixture(:user)
      end

    application_token = fixture(:application_token, user.id)

    {:ok, task} =
      attrs
      |> Map.put_new(:application_token_id, application_token.id)
      |> Enum.into(%{
        attempts: 42,
        date_in: "2010-04-17T14:00:00Z",
        date_last_dispatch: "2010-04-17T14:00:00Z",
        date_out: "2010-04-17T14:00:00Z",
        flops: 120.5,
        params: %{},
        processing_base_time: 42,
        type: "some type",
        flop: 10.0,
        result: %{},
        is_valid: true,
        client_id: "1"
      })
      |> Processing.create_task()

    task
  end

  def channel_fixture(user_id \\ nil) do
    user =
      case user_id do
        nil -> user_fixture()
        id -> Users.get_user!(id)
      end

    user.uuid <> ":" <> UUID.uuid4()
  end

  def worker_slot_fixture(user_id),
    do: %{
      channel_id: user_id |> channel_fixture(),
      tid: UUID.uuid4()
    }
end

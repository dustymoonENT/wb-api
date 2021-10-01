defmodule MotivusWbApi.Fixtures do
  @moduledoc false

  alias MotivusWbApi.Users

  def fixture(:user) do
    with {:ok, user} <-
           Users.create_user(%{
             avatar: "some avatar",
             is_guest: true,
             last_sign_in: "2010-04-17T14:00:00Z",
             mail: "some mail",
             name: "some name",
             provider: "some provider",
             uuid: "7488a646-e31f-11e4-aace-600308960662"
           }) do
      user
    end
  end

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
end

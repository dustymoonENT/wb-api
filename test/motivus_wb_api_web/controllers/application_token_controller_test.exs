defmodule MotivusWbApiWeb.ApplicationTokenControllerTest do
  use MotivusWbApiWeb.ConnCase
  import MotivusWbApi.AuthControllerCase

  alias MotivusWbApi.Users
  alias MotivusWbApi.Users.ApplicationToken
  alias MotivusWbApi.Fixtures

  @create_attrs %{
    description: "some description",
    value: "some value",
    valid: true
  }
  @update_attrs %{
    description: "some updated description",
    value: "some updated value",
    valid: false
  }
  @invalid_attrs %{description: nil, value: nil, valid: 2}

  setup :with_auth

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all application_tokens", %{conn: conn, user: user} do
      conn = get(conn, Routes.users_user_application_token_path(conn, :index, user))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create application_token" do
    test "renders application_token when data is valid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.users_user_application_token_path(conn, :create, user),
          application_token: @create_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.users_user_application_token_path(conn, :show, user, id))

      assert %{
               "id" => id,
               "description" => "some description"
             } = json_response(conn, 200)["data"]

      %{
        "value" => value
      } = json_response(conn, 200)["data"]

      assert value |> String.starts_with?("MWBat")
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.users_user_application_token_path(conn, :create, user),
          application_token: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update application_token" do
    setup [:create_application_token]

    test "renders application_token when data is valid", %{
      conn: conn,
      user: user,
      application_token: %ApplicationToken{id: id} = application_token
    } do
      conn =
        put(
          conn,
          Routes.users_user_application_token_path(conn, :update, user, application_token),
          application_token: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.users_user_application_token_path(conn, :show, user, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "value" => application_token.value,
               "valid" => false
             } == json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      user: user,
      application_token: application_token
    } do
      conn =
        put(
          conn,
          Routes.users_user_application_token_path(conn, :update, user, application_token),
          application_token: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete application_token" do
    setup [:create_application_token]

    test "deletes chosen application_token", %{
      conn: conn,
      user: user,
      application_token: application_token
    } do
      conn =
        delete(
          conn,
          Routes.users_user_application_token_path(conn, :delete, user, application_token)
        )

      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.users_user_application_token_path(conn, :show, user, application_token))
      end
    end
  end

  defp create_application_token(%{user: user}) do
    application_token = Fixtures.fixture(:application_token, user.id)
    %{application_token: application_token}
  end
end

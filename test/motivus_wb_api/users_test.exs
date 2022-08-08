defmodule MotivusWbApi.UsersTest do
  use MotivusWbApi.DataCase

  alias MotivusWbApi.Users

  describe "users" do
    alias MotivusWbApi.Users.User

    @valid_attrs %{
      avatar: "some avatar",
      is_guest: true,
      last_sign_in: "2010-04-17T14:00:00Z",
      mail: nil,
      # mail: "some mail",
      name: "some name",
      provider: "some provider",
      uuid: "7488a646-e31f-11e4-aace-600308960662",
      is_trusted_worker: false
    }
    @update_attrs %{
      avatar: "some updated avatar",
      is_guest: false,
      last_sign_in: "2011-05-18T15:01:01Z",
      mail: "some updated mail",
      name: "some updated name",
      provider: "some updated provider",
      uuid: "7488a646-e31f-11e4-aace-600308960668",
      is_trusted_worker: true
    }
    @invalid_attrs %{
      avatar: nil,
      is_guest: nil,
      last_sign_in: nil,
      mail: nil,
      name: nil,
      provider: nil,
      uuid: nil,
      is_trusted_worker: nil
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Users.create_user(@valid_attrs)
      assert user.avatar == "some avatar"
      assert user.is_guest == true
      assert user.last_sign_in == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert user.mail == nil
      assert user.name == "some name"
      assert user.provider == "some provider"
      assert user.uuid == "7488a646-e31f-11e4-aace-600308960662"
      assert user.is_trusted_worker == false
    end

    test "create_user/1 unique email" do
      assert {:ok, _} = Users.create_user(@valid_attrs)
      assert {:ok, _} = Users.create_user(@valid_attrs)
      assert {:ok, _} = Users.create_user(%{mail: "mail"} |> Enum.into(@valid_attrs))
      assert {:error, chset} = Users.create_user(%{mail: "mail"} |> Enum.into(@valid_attrs))

      assert "has already been taken" in errors_on(chset).mail
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Users.update_user(user, @update_attrs)
      assert user.avatar == "some updated avatar"
      assert user.is_guest == false
      assert user.last_sign_in == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert user.mail == "some updated mail"
      assert user.name == "some updated name"
      assert user.provider == "some updated provider"
      assert user.uuid == "7488a646-e31f-11e4-aace-600308960668"
      assert user.is_trusted_worker == true
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end

  # describe "application_tokens" do
  #   alias MotivusWbApi.Users.ApplicationToken

  #   @valid_attrs %{description: "some description", value: "some value"}
  #   @update_attrs %{description: "some updated description", value: "some updated value"}
  #   @invalid_attrs %{description: nil, value: nil}

  #   def application_token_fixture(attrs \\ %{}) do
  #     {:ok, application_token} =
  #       attrs
  #       |> Enum.into(@valid_attrs)
  #       |> Users.create_application_token()

  #     application_token
  #   end

  #   test "list_application_tokens/0 returns all application_tokens" do
  #     application_token = application_token_fixture()
  #     assert Users.list_application_tokens() == [application_token]
  #   end

  #   test "get_application_token!/1 returns the application_token with given id" do
  #     application_token = application_token_fixture()
  #     assert Users.get_application_token!(application_token.id) == application_token
  #   end

  #   test "create_application_token/1 with valid data creates a application_token" do
  #     assert {:ok, %ApplicationToken{} = application_token} = Users.create_application_token(@valid_attrs)
  #     assert application_token.description == "some description"
  #     assert application_token.value == "some value"
  #   end

  #   test "create_application_token/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Users.create_application_token(@invalid_attrs)
  #   end

  #   test "update_application_token/2 with valid data updates the application_token" do
  #     application_token = application_token_fixture()
  #     assert {:ok, %ApplicationToken{} = application_token} = Users.update_application_token(application_token, @update_attrs)
  #     assert application_token.description == "some updated description"
  #     assert application_token.value == "some updated value"
  #   end

  #   test "update_application_token/2 with invalid data returns error changeset" do
  #     application_token = application_token_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Users.update_application_token(application_token, @invalid_attrs)
  #     assert application_token == Users.get_application_token!(application_token.id)
  #   end

  #   test "delete_application_token/1 deletes the application_token" do
  #     application_token = application_token_fixture()
  #     assert {:ok, %ApplicationToken{}} = Users.delete_application_token(application_token)
  #     assert_raise Ecto.NoResultsError, fn -> Users.get_application_token!(application_token.id) end
  #   end

  #   test "change_application_token/1 returns a application_token changeset" do
  #     application_token = application_token_fixture()
  #     assert %Ecto.Changeset{} = Users.change_application_token(application_token)
  #   end
  # end
end

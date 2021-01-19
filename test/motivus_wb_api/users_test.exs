defmodule MotivusWbApi.UsersTest do
  use MotivusWbApi.DataCase

  alias MotivusWbApi.Users

  describe "users" do
    alias MotivusWbApi.Users.User

    @valid_attrs %{avatar: "some avatar", is_guest: true, last_sign_in: "2010-04-17T14:00:00Z", mail: "some mail", name: "some name", provider: "some provider", uuid: "7488a646-e31f-11e4-aace-600308960662"}
    @update_attrs %{avatar: "some updated avatar", is_guest: false, last_sign_in: "2011-05-18T15:01:01Z", mail: "some updated mail", name: "some updated name", provider: "some updated provider", uuid: "7488a646-e31f-11e4-aace-600308960668"}
    @invalid_attrs %{avatar: nil, is_guest: nil, last_sign_in: nil, mail: nil, name: nil, provider: nil, uuid: nil}

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
      assert user.mail == "some mail"
      assert user.name == "some name"
      assert user.provider == "some provider"
      assert user.uuid == "7488a646-e31f-11e4-aace-600308960662"
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
end

defmodule ExTrue.AccountsTest do
  use ExTrue.DataCase

  alias ExTrue.Accounts

  describe "users" do
    alias ExTrue.Accounts.User

    @valid_attrs %{email: "email@example.com", password: "some password_hash"}
    @update_attrs %{email: "newemail@example.com", password: "some updated password_hash"}
    @invalid_attrs %{email: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      %User{id: id} = user_fixture()
      %User{id: id2} = user_fixture(email: "email2@example.com")
      assert [%User{id: ^id}, %User{id: ^id2}] = Accounts.list_users()
    end

    test "get_user!/1 returns the user with given id" do
      %User{id: id, email: email} = user_fixture()
      assert %User{id: ^id, email: ^email} = Accounts.get_user!(id)
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "email@example.com"
      refute user.password_hash == "some password_hash"
      assert user.password == "some password_hash"
      assert %User{password: nil} = Accounts.get_user!(user.id)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{email: "no at sign", passowrd: "no"})
    end

    test "update_user/2 with valid data updates the user" do
      og_user = user_fixture()
      assert Pbkdf2.verify_pass("some password_hash", og_user.password_hash)
      assert {:ok, %User{} = user} = Accounts.update_user(og_user, @update_attrs)
      assert user.email == "newemail@example.com"
      refute Pbkdf2.verify_pass("some password_hash", user.password_hash)
      assert Pbkdf2.verify_pass("some updated password_hash", user.password_hash)
    end

    test "update_user/2 with invalid data returns error changeset" do
      %User{id: id} = user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert %User{id: ^id} = Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end

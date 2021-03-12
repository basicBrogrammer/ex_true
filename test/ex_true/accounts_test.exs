defmodule ExTrue.AccountsTest do
  use ExTrue.DataCase
  use Bamboo.Test

  alias ExTrue.Accounts

  describe "users" do
    alias ExTrue.Accounts.User

    @valid_attrs %{email: "email@example.com", password: "password"}
    @update_attrs %{email: "newemail@example.com", password: "newpassword"}
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
      refute user.password_hash == "password"
      assert user.password == "password"

      assert user.confirmation_token > 99999
      assert user.confirmation_token < 999_999
      assert user.confirmed_at == nil

      assert %User{confirmation_sent_at: confirmation_sent_at} = Accounts.get_user!(user.id)

      assert NaiveDateTime.to_date(confirmation_sent_at) ==
               NaiveDateTime.to_date(NaiveDateTime.local_now())

      assert %User{password: nil} = Accounts.get_user!(user.id)
    end

    test "create_user/1 sends a confirmation email" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)

      expected_email = ExTrue.Accounts.Email.confirmation_email(user)

      assert_delivered_email(expected_email)

      assert expected_email.html_body =~
               "<p>Your confirmation code is #{user.confirmation_token}</p>"

      assert expected_email.text_body =~
               "Your confirmation code is #{user.confirmation_token}"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{email: "no at sign", passowrd: "no"})

      assert_no_emails_delivered()
    end

    test "update_user/2 with valid data updates the user" do
      og_user = user_fixture()
      assert Pbkdf2.verify_pass("password", og_user.password_hash)
      assert {:ok, %User{} = user} = Accounts.update_user(og_user, @update_attrs)
      assert user.email == "newemail@example.com"
      refute Pbkdf2.verify_pass("password", user.password_hash)
      assert Pbkdf2.verify_pass("newpassword", user.password_hash)
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

    test "verify_user/2 [confirmation] confirms the user's registration" do
      user = user_fixture()
      assert user.confirmed_at == nil
      assert user.confirmation_token |> is_integer

      {:ok, user} =
        Accounts.verify_user(%{
          "type" => "signup",
          "token" => user.confirmation_token,
          "password" => @valid_attrs.password
        })

      refute user.confirmed_at == nil
      assert user.confirmation_token == nil

      assert NaiveDateTime.to_date(user.confirmed_at) ==
               NaiveDateTime.to_date(NaiveDateTime.local_now())
    end

    test "verify_user/2 [confirmation] with an incorrect password" do
      user = user_fixture()
      assert user.confirmed_at == nil
      assert user.confirmation_token |> is_integer

      assert {:error, :unauthorized} =
               Accounts.verify_user(%{
                 "type" => "signup",
                 "token" => user.confirmation_token,
                 "password" => "invalid"
               })

      user = Accounts.get_user!(user.id)
      assert user.confirmed_at == nil
      assert user.confirmation_token |> is_integer
    end
  end
end

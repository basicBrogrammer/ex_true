defmodule ExTrueWeb.UserControllerTest do
  use ExTrueWeb.ConnCase
  use Bamboo.Test

  alias ExTrue.Accounts

  @create_attrs %{email: "email@example.com", password: "some password_hash"}
  # @update_attrs %{email: "newemail@example.com", password: "some updated password_hash"}
  @invalid_attrs %{email: nil, password: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      assert length(Accounts.list_users()) == 0
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert length(Accounts.list_users()) == 1

      assert %{
               "id" => id,
               "email" => "email@example.com",
               "confirmation_sent_at" => "tbd",
               "created_at" => created_at,
               "updated_at" => updated_at
             } = json_response(conn, 201)["data"]

      expected_email = ExTrue.Accounts.Email.confirmation_email(Accounts.get_user!(id))
      assert_delivered_email(expected_email)

      assert String.match?(
               created_at,
               ~r/(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2})/
             )

      assert created_at == updated_at
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)

      assert json_response(conn, 422)["errors"] == %{
               "email" => ["can't be blank"],
               "password" => ["can't be blank"]
             }
    end
  end

  # describe "update user" do
  #   setup [:create_user]

  #   test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
  #     assert Pbkdf2.verify_pass("some password_hash", user.password_hash)
  #     conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get(conn, Routes.user_path(conn, :show, id))

  #     assert %{
  #              "id" => id,
  #              "email" => "newemail@example.com"
  #            } = json_response(conn, 200)["data"]

  #     %User{password_hash: pass} = Accounts.get_user!(id)

  #     assert Pbkdf2.verify_pass("some updated password_hash", pass)
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, user: user} do
  #     conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete user" do
  #   setup [:create_user]

  #   test "deletes chosen user", %{conn: conn, user: user} do
  #     conn = delete(conn, Routes.user_path(conn, :delete, user))
  #     assert response(conn, 204)

  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.user_path(conn, :show, user))
  #     end
  #   end
  # end

  # defp create_user(_) do
  #   user = fixture(:user)
  #   %{user: user}
  # end
end

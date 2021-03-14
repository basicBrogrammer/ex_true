defmodule ExTrueWeb.VerificationControllerTest do
  use ExTrueWeb.ConnCase

  alias ExTrue.Accounts

  describe "confirmation token" do
    @valid_params %{type: "signup", token: 123_456, password: "12345abcdef"}

    setup [:create_user]

    # TODO: consolidate
    def fixture(:user) do
      {:ok, user} =
        Accounts.create_user(%{
          email: "email@example.com",
          confirmation_token: @valid_params.token,
          password: @valid_params.password
        })

      user
    end

    test "renders the JWT & refresh token when data is valid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.verification_path(conn, :create), %{
          type: "signup",
          token: user.confirmation_token,
          password: @valid_params.password
        })

      assert json_response(conn, 201) == %{
               "id" => user.id,
               "access_token" => "jwt-token-representing-the-user",
               "token_type" => "bearer",
               "expires_in" => 3600,
               "refresh_token" => "a-refresh-token"
             }
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.verification_path(conn, :create), %{
          type: "signup",
          token: user.confirmation_token + 1,
          password: @valid_params.password
        })

      assert json_response(conn, 404) == "Not Found"

      conn =
        post(conn, Routes.verification_path(conn, :create), %{
          type: "signup",
          token: user.confirmation_token,
          password: "invalid"
        })

      assert json_response(conn, 401) == "Unauthorized"
    end

    defp create_user(_) do
      user = fixture(:user)
      %{user: user}
    end
  end
end

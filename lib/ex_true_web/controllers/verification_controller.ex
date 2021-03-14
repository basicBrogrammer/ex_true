defmodule ExTrueWeb.VerificationController do
  use ExTrueWeb, :controller

  alias ExTrue.Accounts
  alias ExTrue.Accounts.User

  action_fallback ExTrueWeb.FallbackController

  def create(conn, verification_params) do
    with {:ok, %User{} = user} <- Accounts.verify_user(verification_params) do
      conn
      |> put_status(:created)
      |> render("confirmation.json", user: user)
    end
  end
end

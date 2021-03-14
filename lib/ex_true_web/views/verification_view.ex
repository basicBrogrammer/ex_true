defmodule ExTrueWeb.VerificationView do
  use ExTrueWeb, :view

  def render("confirmation.json", %{user: user}) do
    %{
      id: user.id,
      access_token: "jwt-token-representing-the-user",
      token_type: "bearer",
      expires_in: 3600,
      refresh_token: "a-refresh-token"
    }
  end
end

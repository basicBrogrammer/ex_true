defmodule ExTrueWeb.UserView do
  use ExTrueWeb, :view
  alias ExTrueWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      created_at: user.inserted_at,
      updated_at: user.updated_at,
      confirmation_sent_at: user.confirmation_sent_at
    }
  end
end

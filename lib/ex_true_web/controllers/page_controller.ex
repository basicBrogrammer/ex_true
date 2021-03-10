defmodule ExTrueWeb.PageController do
  use ExTrueWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

defmodule ExTrueWeb.PageControllerTest do
  use ExTrueWeb.ConnCase

  test "GET /admin", %{conn: conn} do
    conn = get(conn, "/admin")
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end

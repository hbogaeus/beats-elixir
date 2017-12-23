defmodule BeatsWeb.SearchControllerTest do
  use BeatsWeb.ConnCase

  test "POST /search", %{conn: conn} do
    conn = post conn, "/api/search", %{"query" => "Something"}
    assert json_response(conn, 200)
  end
end
defmodule BeatsWeb.PageControllerTest do
  use BeatsWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert conn.status == 200
  end
end

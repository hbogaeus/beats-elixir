defmodule BeatsWeb.SearchController do
  use BeatsWeb, :controller

  def search(conn, %{"query" => query}) do
    data = Beats.Search.search(query)
    json(conn, %{data: data})
  end
end
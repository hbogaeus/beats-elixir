defmodule Beats.Search do
  alias Beats.Search.SpotifyApi

  def search(query) do
    with  {:ok, result} <- SpotifyApi.search(query),
          song_ids <- Enum.map(result, &(&1["id"])),
          {:ok, bpms} <- SpotifyApi.bpms(song_ids)
    do
      zipped_results = Enum.zip(result, bpms)
      Enum.map(zipped_results, fn {item, bpm} -> 
        %{
          id: item["id"],
          bpm: bpm,
          href: item["href"],
          title: item["name"],
          artist: get_in(item, ["artists", fn (:get, data, _next) -> Map.get(hd(data), "name") end ]),
          image_url: get_in(item, ["album", "images", fn (:get, data, _next) -> Map.get(hd(data), "url") end])
        }
      end)
    else
      {:error, error} ->
        {:error, error}
    end
  end
end
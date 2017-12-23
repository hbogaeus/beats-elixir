defmodule Beats.Spotify do
    defp encoded_id_and_secret do
        client_id = System.get_env("SPOTIFY_CLIENT_ID")
        client_secret = System.get_env("SPOTIFY_SECRET")
        Base.encode64("#{client_id}:#{client_secret}")
    end

    def request_access_token do
        url = "https://accounts.spotify.com/api/token"
        body = {:form, [grant_type: "client_credentials"]}
        headers = %{
            "Content-Type" => "application/x-www-form-urlencoded",
            "Authorization" => "Basic #{encoded_id_and_secret()}"
        }

        case HTTPoison.post(url, body, headers) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                body = Poison.decode!(body)
                token = body["access_token"]
                {:ok, token}
            {:ok, %HTTPoison.Response{status_code: 400}} ->
                {:error, "Not found."}
            {:ok, %HTTPoison.Response{status_code: 429}} ->
                {:error, "Rate limit hit."}
            {:error, %HTTPoison.Error{reason: reason}} ->
                {:error, "#{inspect reason}"}
        end
    end

    def search(query) do
        {:ok, token} = request_access_token()
        headers = %{
            "Authorization" => "Bearer #{token}"
        }

        query_string = %{
            "q" => query,
            "type" => "track"
        }

        url = "https://api.spotify.com/v1/search?" <> URI.encode_query(query_string)

        case HTTPoison.get(url, headers) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                body = Poison.decode!(body)
                ids =
                    body
                    |> get_in(["tracks", "items"])
                    |> Enum.map(&(&1["id"]))

                {:ok, ids}
            {:ok, %HTTPoison.Response{status_code: 400}} ->
                {:error, "Not found."}
            {:ok, %HTTPoison.Response{status_code: 429}} ->
                {:error, "Rate limit hit."}
            {:error, %HTTPoison.Error{reason: reason}} ->
                {:error, "#{inspect reason}"}
        end
    end

    def bpm(ids) do
        {:ok, token} = request_access_token()
        headers = %{
            "Authorization" => "Bearer #{token}"
        }

        url = "https://api.spotify.com/v1/audio-features/?ids=" <> Enum.join(ids, ",")

        case HTTPoison.get(url, headers) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                body = Poison.decode!(body)
                {:ok, body}
            {:ok, %HTTPoison.Response{status_code: 400}} ->
                {:error, "Not found."}
            {:ok, %HTTPoison.Response{status_code: 429}} ->
                {:error, "Rate limit hit."}
            {:error, %HTTPoison.Error{reason: reason}} ->
                {:error, "#{inspect reason}"}
        end
        
    end
end
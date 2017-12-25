defmodule Beats.Search.SpotifyApi do
    use GenServer
    require Logger
    
    def init(_args) do
      Logger.debug "Started GenServer."
      {:ok, nil}
    end 

    def start_link do
      GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    end

    def handle_call(:get, _from, token) do
      Logger.debug "Replied with #{inspect token}."
      {:reply, token, token}
    end

    def handle_call({:update, token} , _from, _state) do
      Logger.debug "Updated state to #{inspect token}."
      {:reply, :ok, token}
    end

    def handle_info(:clear, _state) do
      Logger.debug "Cleared state."
      {:noreply, nil}
    end

    defp encoded_id_and_secret do
        client_id = System.get_env("SPOTIFY_CLIENT_ID")
        client_secret = System.get_env("SPOTIFY_SECRET")
        Base.encode64("#{client_id}:#{client_secret}")
    end

    defp get_access_token do
      token = GenServer.call(__MODULE__, :get)

      if token do
        {:ok, token}
      else
        {:ok, response} = request_access_token()
        new_token = response["access_token"]
        expires_in = response["expires_in"]

        GenServer.call(__MODULE__, {:update, new_token})
        Process.send_after(__MODULE__, :clear, (expires_in - 10) * 1000)

        {:ok, new_token}
      end
    end

    defp request_access_token do
        url = "https://accounts.spotify.com/api/token"
        body = {:form, [grant_type: "client_credentials"]}
        headers = %{
            "Content-Type" => "application/x-www-form-urlencoded",
            "Authorization" => "Basic #{encoded_id_and_secret()}"
        }

        case HTTPoison.post(url, body, headers) do
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

    def search(query) do
        {:ok, token} = get_access_token()
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
                result =
                  Poison.decode!(body)
                  |> get_in(["tracks", "items"])
                {:ok, result}
            {:ok, %HTTPoison.Response{status_code: 400}} ->
                {:error, "Not found."}
            {:ok, %HTTPoison.Response{status_code: 429}} ->
                {:error, "Rate limit hit."}
            {:error, %HTTPoison.Error{reason: reason}} ->
                {:error, "#{inspect reason}"}
        end
    end

    def bpms(ids) do
        {:ok, token} = get_access_token()
        headers = %{
            "Authorization" => "Bearer #{token}"
        }

        url = "https://api.spotify.com/v1/audio-features/?ids=" <> Enum.join(ids, ",")

        case HTTPoison.get(url, headers) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                result =
                  Poison.decode!(body)
                  |> Map.get("audio_features")
                  |> Enum.map(&(&1["tempo"]))
                
                {:ok, result}
            {:ok, %HTTPoison.Response{status_code: 400}} ->
                {:error, "Not found."}
            {:ok, %HTTPoison.Response{status_code: 429}} ->
                {:error, "Rate limit hit."}
            {:error, %HTTPoison.Error{reason: reason}} ->
                {:error, "#{inspect reason}"}
        end
        
    end
end
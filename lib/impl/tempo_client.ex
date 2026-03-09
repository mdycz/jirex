defmodule Jira.Impl.TempoClient do
  @base_tempo_url "https://api.tempo.io/4"

  defstruct [:auth_token, base_url: @base_tempo_url]

  def new(%{auth_token: _auth_token} = config) do
    struct(__MODULE__, config)
  end

  def request_base(client) do
    [base_url: @base_tempo_url, headers: headers(client)]
    |> Keyword.merge(Application.get_env(:jira, :tempo_req_options, []))
    |> Req.new()
  end

  defp headers(client) do
    %{
      Authorization: "Bearer #{client.auth_token}"
    }
  end
end

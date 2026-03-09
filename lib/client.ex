defmodule Jira.Client do
  alias Jira.Impl.TempoClient

  @base_url "https://observatory.atlassian.net/rest/api/3"

  @enforce_keys [:auth_token, :account_id, :account_email, :tempo_client]
  defstruct [:auth_token, :account_id, :account_email, :tempo_client, base_url: @base_url]

  def new(
        %{
          auth_token: auth_token,
          account_id: account_id,
          account_email: account_email,
          tempo_token: tempo_token
        } = config
      ) do
    %__MODULE__{
      auth_token: auth_token,
      account_id: account_id,
      account_email: account_email,
      tempo_client: TempoClient.new(%{auth_token: tempo_token}),
      base_url: Map.get(config, :base_url, @base_url)
    }
  end

  def request_base(%{base_url: base_url} = client) do
    [base_url: base_url, headers: headers(client), http_errors: :raise]
    |> Keyword.merge(Application.get_env(:jira, :req_options, []))
    |> Req.new()
  end

  defp headers(client) do
    %{
      "Authorization" => auth_header(client),
      "Accept" => "application/json",
      "Content-Type" => "application/json"
    }
  end

  defp auth_header(%{account_email: account_email, auth_token: auth_token} = _client) do
    token = Base.encode64("#{account_email}:#{auth_token}")

    "Basic #{token}"
  end
end

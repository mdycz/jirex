defmodule Jira.Impl.Issues do
  @per_page 100
  @default_jql "statusCategory != Done"

  def get_issue(client, id) do
    Req.get!(Jira.Client.request_base(client), url: "/issue/#{id}").body
  end

  @doc """
  List issues for a project via the `/search/jql` cursor-paginated endpoint.

  ## Options
    * `:jql` - clause appended after `project = <project_id> AND`. Defaults to
      `"statusCategory != Done"` so closed issues are omitted.
    * `:fields` - comma-separated Jira fields to return. Defaults to `"summary"`.
  """
  def list_for_project(client, project_id, opts \\ []) do
    jql = "project = #{project_id} AND " <> Keyword.get(opts, :jql, @default_jql)
    fields = Keyword.get(opts, :fields, "summary")
    do_list(client, jql, fields, nil, [])
  end

  defp do_list(client, jql, fields, next_page_token, acc) do
    params =
      %{jql: jql, fields: fields, maxResults: @per_page}
      |> maybe_put_token(next_page_token)

    request =
      Req.merge(Jira.Client.request_base(client),
        url: "/search/jql",
        params: params,
        http_errors: :return
      )

    case Req.get!(request) do
      %{status: status, body: body} when status >= 200 and status < 400 ->
        issues = body["issues"] || []
        acc = acc ++ issues

        case body["nextPageToken"] do
          nil -> {:ok, acc}
          token -> do_list(client, jql, fields, token, acc)
        end

      res ->
        {:error, res}
    end
  end

  defp maybe_put_token(params, nil), do: params
  defp maybe_put_token(params, token), do: Map.put(params, :nextPageToken, token)
end

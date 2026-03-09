defmodule Jira.Impl.Worklogs do
  alias Jira.Impl.TempoClient

  @type list_filters :: %{project_id: integer(), from: Date.t(), to: Date.t(), page: integer()}

  @page_size 200

  def get_worklogs(client, filters) do
    params = worklogs_query(filters)

    case Req.get!(TempoClient.request_base(client.tempo_client),
           url: "/worklogs",
           params: params
         ) do
      res when res.status >= 200 and res.status < 400 ->
        {:ok, res.body}

      res ->
        {:error, res}
    end
  end

  def create_worklog(client, params) do
    case Req.post!(TempoClient.request_base(client.tempo_client),
           url: "/worklogs",
           json: params
         ) do
      res when res.status >= 200 and res.status < 400 ->
        {:ok, res}

      res ->
        {:error, res}
    end
  end

  def delete_worklog(client, worklog_id) do
    case Req.delete!(TempoClient.request_base(client.tempo_client),
           url: "/worklogs/#{worklog_id}"
         ) do
      res when res.status >= 200 and res.status < 400 ->
        :ok

      res ->
        {:error, res}
    end
  end

  defp worklogs_query(%{project_id: project_id, from: from, to: to, page: page}) do
    %{
      projectId: project_id,
      from: from,
      to: to,
      offset: (page - 1) * @page_size,
      limit: @page_size
    }
  end
end

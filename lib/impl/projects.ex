defmodule Jira.Impl.Projects do
  @per_page 200

  def get_list(client, page) do
    client
    |> Jira.Client.request_base()
    |> Req.get!(url: "/project/search", params: %{limit: @per_page, page: page})
  end
end

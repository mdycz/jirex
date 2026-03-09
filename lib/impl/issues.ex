defmodule Jira.Impl.Issues do
  def get_issue(client, id) do
    Req.get!(Jira.Client.request_base(client), url: "/issue/#{id}").body
  end
end

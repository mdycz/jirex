defmodule JiraTest do
  use ExUnit.Case, async: false

  setup do
    Application.put_env(:jira, :req_options, plug: {Req.Test, Jira.Client})
    Application.put_env(:jira, :tempo_req_options, plug: {Req.Test, Jira.Impl.TempoClient})

    on_exit(fn ->
      Application.delete_env(:jira, :req_options)
      Application.delete_env(:jira, :tempo_req_options)
    end)
  end

  test "get_projects/2 delegates to the Jira API" do
    Req.Test.stub(Jira.Client, fn conn ->
      assert String.ends_with?(conn.request_path, "/project/search")
      Req.Test.json(conn, %{"values" => [%{"id" => "10000"}]})
    end)

    client =
      Jira.Client.new(%{
        auth_token: "jira-token",
        account_id: "account-id",
        account_email: "user@example.com",
        tempo_token: "tempo-token"
      })

    response = Jira.get_projects(client, 1)

    assert response.body == %{"values" => [%{"id" => "10000"}]}
  end

  test "create_worklog/2 delegates to the Tempo API" do
    Req.Test.stub(Jira.Impl.TempoClient, fn conn ->
      assert conn.method == "POST"
      assert String.ends_with?(conn.request_path, "/worklogs")
      Req.Test.json(conn, %{"tempoWorklogId" => 123})
    end)

    client =
      Jira.Client.new(%{
        auth_token: "jira-token",
        account_id: "account-id",
        account_email: "user@example.com",
        tempo_token: "tempo-token"
      })

    assert {:ok, response} = Jira.create_worklog(client, %{timeSpentSeconds: 900})
    assert response.body == %{"tempoWorklogId" => 123}
  end
end

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

  test "list_issues_for_project/2 hits /search/jql with default JQL and pagination params" do
    Req.Test.stub(Jira.Client, fn conn ->
      assert conn.method == "GET"
      assert String.ends_with?(conn.request_path, "/search/jql")

      params = URI.decode_query(conn.query_string)
      assert params["jql"] == "project = 10000 AND statusCategory != Done"
      assert params["fields"] == "summary"
      assert params["maxResults"] == "100"
      refute Map.has_key?(params, "nextPageToken")

      Req.Test.json(conn, %{"issues" => [%{"id" => "1", "key" => "PROJ-1"}]})
    end)

    client =
      Jira.Client.new(%{
        auth_token: "jira-token",
        account_id: "account-id",
        account_email: "user@example.com",
        tempo_token: "tempo-token"
      })

    assert {:ok, [%{"id" => "1", "key" => "PROJ-1"}]} =
             Jira.list_issues_for_project(client, "10000")
  end

  test "list_issues_for_project/2 follows nextPageToken and concatenates results" do
    {:ok, agent} = Agent.start_link(fn -> 0 end)

    Req.Test.stub(Jira.Client, fn conn ->
      call = Agent.get_and_update(agent, fn n -> {n, n + 1} end)
      params = URI.decode_query(conn.query_string)

      case call do
        0 ->
          refute Map.has_key?(params, "nextPageToken")

          Req.Test.json(conn, %{
            "issues" => [%{"id" => "1"}],
            "nextPageToken" => "tok-2"
          })

        1 ->
          assert params["nextPageToken"] == "tok-2"
          Req.Test.json(conn, %{"issues" => [%{"id" => "2"}]})
      end
    end)

    client =
      Jira.Client.new(%{
        auth_token: "jira-token",
        account_id: "account-id",
        account_email: "user@example.com",
        tempo_token: "tempo-token"
      })

    assert {:ok, [%{"id" => "1"}, %{"id" => "2"}]} =
             Jira.list_issues_for_project(client, "10000")

    assert Agent.get(agent, & &1) == 2
  end

  test "list_issues_for_project/3 appends a custom JQL clause" do
    Req.Test.stub(Jira.Client, fn conn ->
      params = URI.decode_query(conn.query_string)
      assert params["jql"] == "project = 10000 AND assignee = currentUser()"
      Req.Test.json(conn, %{"issues" => []})
    end)

    client =
      Jira.Client.new(%{
        auth_token: "jira-token",
        account_id: "account-id",
        account_email: "user@example.com",
        tempo_token: "tempo-token"
      })

    assert {:ok, []} =
             Jira.list_issues_for_project(client, "10000", jql: "assignee = currentUser()")
  end

  test "list_issues_for_project/2 returns an error tuple on non-2xx responses" do
    Req.Test.stub(Jira.Client, fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(400, Jason.encode!(%{"errorMessages" => ["Bad JQL"]}))
    end)

    client =
      Jira.Client.new(%{
        auth_token: "jira-token",
        account_id: "account-id",
        account_email: "user@example.com",
        tempo_token: "tempo-token"
      })

    assert {:error, %Req.Response{status: 400}} =
             Jira.list_issues_for_project(client, "10000")
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

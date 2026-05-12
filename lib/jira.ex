defmodule Jira do
  @moduledoc """
  Simple wrapper over Jira (and Tempo) REST API
  """
  alias Jira.Impl.Worklogs
  alias Jira.Impl.Issues
  alias Jira.Impl.Projects

  @spec get_worklogs(%Jira.Client{}, Worklogs.list_filters()) :: any()
  defdelegate get_worklogs(client, filters), to: Worklogs

  @spec get_issue(%Jira.Client{}, integer()) :: any()
  defdelegate get_issue(client, id), to: Issues

  @spec list_issues_for_project(%Jira.Client{}, String.t() | integer(), keyword()) ::
          {:ok, [map()]} | {:error, term()}
  defdelegate list_issues_for_project(client, project_id, opts \\ []),
    to: Issues,
    as: :list_for_project

  @spec get_projects(%Jira.Client{}, integer()) :: any()
  defdelegate get_projects(client, page), to: Projects, as: :get_list

  @spec create_worklog(%Jira.Client{}, map()) :: {:ok, any()} | {:error, any()}
  defdelegate create_worklog(client, params), to: Worklogs

  @spec delete_worklog(%Jira.Client{}, term()) :: any()
  defdelegate delete_worklog(client, worklog_id), to: Worklogs
end

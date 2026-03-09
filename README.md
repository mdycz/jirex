# Jira

A small Elixir client for the Jira REST API plus Tempo worklog endpoints used by `intranet`.

## Installation

Add `jira` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jira, git: "https://github.com/<org>/jira.git", tag: "v0.1.0"}
  ]
end
```

## Usage

```elixir
client =
  Jira.Client.new(%{
    auth_token: "...",
    account_id: "...",
    account_email: "user@example.com",
    tempo_token: "..."
  })

Jira.get_projects(client, 1)
```

## Development

```bash
mix deps.get
mix test
```

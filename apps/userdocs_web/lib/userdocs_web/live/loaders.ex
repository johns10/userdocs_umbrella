defmodule UserDocsWeb.Loaders do
  require Logger

  alias UserDocs.Documents
  alias UserDocs.Media
  alias UserDocs.Projects

  def projects(%{ assigns: %{ current_user: current_user } } = socket) do
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:filters, %{ user_id: current_user.id })

    Projects.load_projects(socket, opts)
  end

  def versions(%{ assigns: %{ current_user: current_user } } = socket) do
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:filters, %{ user_id: current_user.id })

    Projects.load_versions(socket, opts)
  end

    opts =
      opts
      |> Keyword.put(:filters, %{team_id: current_team_id})
      |> Keyword.put(:params, %{ content_versions: true })


    Documents.load_content(socket, opts)
  end

  def load_content_versions(socket, opts) do
    content_ids = Enum.map(Documents.list_content(socket, opts),
      fn(c) -> c.id end)

    opts =
      opts
      |> Keyword.put(:filters, %{content_ids: content_ids})

    Documents.load_content_versions(socket, opts)
  end

  def screenshots(socket, opts) do
    Media.load_screenshots(socket, opts)
  end
end

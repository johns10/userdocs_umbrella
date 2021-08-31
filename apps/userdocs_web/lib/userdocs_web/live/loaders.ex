defmodule UserDocsWeb.Loaders do
  require Logger

  alias UserDocs.Documents
  alias UserDocs.Media
  alias UserDocs.Projects

  def projects(%{assigns: %{current_user: current_user}} = socket) do
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:filters, %{user_id: current_user.id})

    Projects.load_projects(socket, opts)
  end

  def versions(%{assigns: %{current_user: current_user}} = socket) do
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:filters, %{user_id: current_user.id})

    Projects.load_versions(socket, opts)
  end

  def screenshots(socket, opts) do
    Media.load_screenshots(socket, opts)
  end
end

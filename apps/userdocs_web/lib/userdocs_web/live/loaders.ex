defmodule UserDocsWeb.Loaders do
  require Logger

  alias UserDocs.Documents
  alias UserDocs.Media

  def load_content(%{ assigns: %{ current_team_id: current_team_id }} = socket, opts) do
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

defmodule UserDocsWeb.DocumentLive.Loaders do
  require Logger

  alias UserDocs.Documents
  alias UserDocs.Automation
  alias UserDocs.Media
  alias UserDocs.Web

  def load_document(socket, document, opts) do
    StateHandlers.load(socket, [ document ], opts)
  end

  def load_pages(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{version: socket.assigns.current_version_id})

    Web.load_pages(socket, opts)
  end

  def load_processes(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{version: socket.assigns.current_version_id})

    Automation.load_processes(socket, opts)
  end

  def load_files(socket, opts) do
    Media.load_files(socket, opts)
  end

  def load_steps(socket, opts) do
    params = %{
      screenshot: true,
      step_type: true,
      annotation: true,
      annotation_type: true,
      content_versions: true,
      file: true
    }
    opts =
      opts
      |> Keyword.put(:filters, %{team_id: socket.assigns.current_team_id})
      |> Keyword.put(:params, params)

    Automation.load_steps(socket, opts)
  end

  def load_language_codes(socket, opts) do
    Documents.load_language_codes(socket, opts)
  end

  def load_document_versions(socket, id, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{document_id: id})

    Documents.load_document_versions(socket, opts)
  end

  def load_docubits(socket, document_version_id, opts) do
    opts =
      opts
      |> Keyword.put(:preloads, [ :content, :file, :through_annotation ])

    docubits =
      Documents.list_docubits(%{},  %{document_version_id: document_version_id })

    StateHandlers.load(socket, docubits, opts)
  end

  def load_content(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{team_id: socket.assigns.current_team_id})
      |> Keyword.put(:params, %{ content_versions: true })


    Documents.load_content(socket, opts)
  end

  def load_content_versions(socket, opts) do
    content_ids = Enum.map(Documents.list_content(socket, opts),
      fn(c) -> c.id end)

    opts =
      opts
      |> Keyword.put(:filters, %{content_ids: content_ids})

    Documents.load_content_version(socket, opts)
  end

  def load_annotations(socket, opts) do
    params = %{ content: true, content_versions: true, annotation_type: true }
    opts =
      opts
      |> Keyword.put(:filters, %{team_id: socket.assigns.current_team_id})
      |> Keyword.put(:params, params)

    Web.load_annotations(socket, opts)
  end
end

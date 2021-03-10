defmodule UserDocsWeb.DocumentLive.Loaders do
  require Logger

  alias UserDocs.Documents
  alias UserDocs.Automation
  alias UserDocs.Media
  alias UserDocs.Web

  alias UserDocsWeb.Loaders

  def load_annotation_types(socket, opts) do
    Web.load_annotation_types(socket, opts)
  end

  def load_document(socket, document, opts) do
    StateHandlers.load(socket, [ document ], opts)
  end

  def load_docubit_types(socket, opts) do
    Documents.load_docubit_types(socket, opts)
  end

  def load_pages(%{ assigns: %{ current_version: current_version }} = socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{version_id: current_version.id})

    Web.load_pages(socket, opts)
  end

  def load_processes(%{ assigns: %{ current_version: current_version }} = socket, opts) do
    IO.puts("loading processes")
    opts =
      opts
      |> Keyword.put(:filters, %{version_id: current_version.id})

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
      content_versions: true
    }
    opts =
      opts
      |> Keyword.put(:filters, %{team_id: socket.assigns.current_team.id})
      |> Keyword.put(:params, params)

    Automation.load_steps(socket, opts)
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

  def load_language_codes(socket, opts), do: Documents.load_language_codes(socket, opts)
  def load_content(socket, opts), do: Loaders.load_content(socket, opts)
  def load_content_versions(socket, opts), do: Loaders.load_content_versions(socket, opts)

  def load_annotations(socket, opts) do
    params = %{ content: true, content_versions: true, annotation_type: true }
    opts =
      opts
      |> Keyword.put(:filters, %{team_id: socket.assigns.current_team.id})
      |> Keyword.put(:params, params)

    Web.load_annotations(socket, opts)
  end
end

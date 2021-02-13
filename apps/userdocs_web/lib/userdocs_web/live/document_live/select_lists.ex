defmodule UserDocsWeb.DocumentLive.SelectLists do
  use UserDocsWeb, :live_view
  alias UserDocs.Documents
  alias UserDocs.Automation
  alias UserDocs.Web

  def render(assigns) do
    ~L"""
    """
  end

  def process(socket, opts) do
    processes = Automation.list_processes(socket, opts)
    socket
    |> assign(:process_select, UserDocs.Helpers.select_list(processes, :name, false))
  end

  def page(socket, opts) do
    page = Web.list_pages(socket, opts)
    socket
    |> assign(:pages_select, UserDocs.Helpers.select_list(page, :name, false))
  end

  def language_code(socket, opts) do
    language_codes = Documents.list_language_codes(socket, opts)
    socket
    |> assign(:language_codes_select, UserDocs.Helpers.select_list(language_codes, :name, false))
  end

  def versions(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filter, { :document_id, socket.assigns.document.id })
      |> Keyword.put(:preloads, [ :version ])

    select_options =
      Documents.list_document_versions(socket, opts)
      |> Enum.map(fn(dv) -> %{ name: dv.version.name, id: dv.id } end)
      |> UserDocs.Helpers.select_list(:name, false)

    socket
    |> assign(:versions_select, select_options)
  end
end

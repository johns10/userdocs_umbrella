defmodule UserDocsWeb.DocumentLive.Viewer do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  require Logger

  alias UserDocsWeb.DocumentLive.Loaders
  alias UserDocsWeb.DocumentLive.SelectLists

  alias UserDocs.Documents
  alias UserDocs.Automation
  alias UserDocs.Projects
  alias UserDocs.Web
  alias UserDocs.Users

  alias UserDocs.Documents
  alias UserDocs.Documents.Document
  alias UserDocs.Documents.Content
  alias UserDocs.Documents.ContentVersion
  alias UserDocs.Documents.Docubit

  alias UserDocsWeb.Root
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.DocubitLive.Renderers.Base

  @types [
    UserDocs.Documents.Document,
    UserDocs.Documents.DocumentVersion,
    UserDocs.Web.Page,
    UserDocs.Automation.Process,
    UserDocs.Documents.Content,
    UserDocs.Documents.ContentVersion,
    UserDocs.Automation.Step,
    UserDocs.Documents.LanguageCode,
    UserDocs.Web.Annotation,
    UserDocs.Documents.Docubit,
    UserDocs.Documents.DocubitType,
    UserDocs.Media.Screenshot,
    UserDocs.Projects.Version,
    UserDocs.Users.Team
]

  @impl true
  def mount(_params, session, socket) do
    opts = Defaults.opts(socket, @types)

    {
      :ok,
      socket
      |> StateHandlers.initialize(opts)
      |> Root.authorize(session)
      |> Root.initialize(opts)
      |> assign(:state_opts, opts)
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{ assigns: %{ auth_state: :logged_in }} = socket) do
    id = String.to_integer(id)
    document = Documents.get_document!(id, %{ document_versions: true })
    opts = Defaults.opts(socket, @types)
    {
      :noreply,
      socket
      |> Loaders.load_docubit_types(opts)
      |> Loaders.load_document(Documents.get_document!(id), opts)
      |> Loaders.load_document_versions(id, opts)
      |> Loaders.load_language_codes(opts)
      |> Loaders.load_pages(opts)
      |> Loaders.load_processes(opts)
      |> Loaders.load_content(opts)
      |> Loaders.load_content_versions(opts)
      |> Loaders.load_steps(opts)
      |> current_selections()
      |> Loaders.load_annotations(opts)
      |> SelectLists.language_code(opts)
      |> prepare_document(document)
      |> default_language_code_id()
      |> (&(Loaders.load_docubits(&1, default_document_version_id(&1, document), opts))).()
      |> (&(prepare_document_version(&1, default_document_version_id(&1, document)))).()
      |> assign(:state_opts, opts)
      |> assign(:img_path, Routes.static_path(socket, "/images/"))
    }
  end
  def handle_params(_, _, socket), do: { :noreply, socket }

  @impl true
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  def handle_info(%{topic: _, event: _, payload: %{ objects: [ %ContentVersion{} | _ ]}} = sub_data, socket) do
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    { :noreply, prepare_document_version(socket, socket.assigns.document_version.id) }
  end
  def handle_info(%{topic: _, event: _, payload: %Content{}} = sub_data, socket) do
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    { :noreply, prepare_document_version(socket, socket.assigns.document_version.id) }
  end
  def handle_info(n, s), do: Root.handle_info(n, s)

  defp prepare_document(socket, document) do
    assign(socket, :document, document)
  end

  def prepare_document_version(socket, document_version_id) do
    IO.puts("prepare_document_version")
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:preloads, [
          :body,
          :docubits,
          :version,
          [ docubits: :content ],
          [ docubits: :through_annotation ],
          [ docubits: :through_step ],
          [ docubits: :docubit_type ],
          [ docubits: [ content: :content_versions ] ],
          [ docubits: [ content: :annotation ] ],
          [ docubits: [ content: [ content_versions: :version ]]]
        ])
      |> Keyword.put(:order, docubits: %{ field: :id, order: :asc })

    document_version = Documents.get_document_version!(document_version_id, socket, opts)

    body =
      document_version.docubits |> Enum.at(0)
      |> Docubit.apply_context(%{ settings: %{} })
      |> prepare_docubit(document_version.docubits)

    document_version = Map.put(document_version, :body, body)

    socket
    |> assign(:document_version, document_version)
  end

  def prepare_docubit(docubit, all_docubits) do
    docubits =
      all_docubits
      |> Enum.filter(fn(d) -> d.docubit_id == docubit.id end)
      |> Enum.sort(&(&1.order <= &2.order))
      |> Enum.map(
        fn(child_docubit) ->
          Docubit.apply_context(child_docubit, docubit.context)
          |> prepare_docubit(all_docubits)
        end)

    Map.put(docubit, :docubits, docubits)
  end

  defp current_selections(socket) do
    process = Automation.list_processes(socket, socket.assigns.state_opts) |> Enum.at(0)
    page = Web.list_pages(socket, socket.assigns.state_opts) |> Enum.at(0)

    socket
    |> assign(:current_page, page)
    |> assign(:current_process, process)
  end

  defp default_language_code_id(socket) do
    language_code_id =
      socket.assigns.current_team
      |> Map.get(:default_language_code_id)

    socket
    |> assign(:current_language_code_id, language_code_id)
  end

  defp default_document_version(_socket, %Document{} = document) do
    document.document_versions
    |> Enum.at(0)
  end
  defp default_document_version_id(socket, document_or_id) do
    default_document_version(socket, document_or_id)
    |> Map.get(:id)
  end
end

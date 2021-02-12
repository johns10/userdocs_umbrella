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

  alias UserDocs.Automation.Process
  alias UserDocs.Automation.Step
  alias UserDocs.Documents
  alias UserDocs.Documents.Document
  alias UserDocs.Documents.Content
  alias UserDocs.Documents.ContentVersion
  alias UserDocs.Documents.DocumentVersion
  alias UserDocs.Documents.LanguageCode
  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents.DocubitType
  alias UserDocs.Web.Page
  alias UserDocs.Web.Annotation
  alias UserDocs.Media.File

  alias UserDocsWeb.Root
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.DocubitLive.Renderers.Base

  @types [  Document, DocumentVersion, Page,
  Process, Content, ContentVersion, Step, LanguageCode, Annotation,
  Docubit, File, DocubitType ]

  defp base_opts() do
    Defaults.state_opts
    |> Keyword.put(:location, :data)
    |> Keyword.put(:types, @types)
  end

  defp state_opts(socket) do
    base_opts()
    |> Keyword.put(:broadcast, true)
    |> Keyword.put(:channel, UserDocsWeb.Defaults.channel(socket))
    |> Keyword.put(:broadcast_function, &UserDocsWeb.Endpoint.broadcast/3)
  end

  @impl true
  def mount(_params, session, socket) do
    opts = base_opts()

    {
      :ok,
      socket
      |> StateHandlers.initialize(opts)
      |> Root.authorize(session)
      |> Root.initialize()
      |> assign(:state_opts, opts)
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{ assigns: %{ auth_state: :logged_in }} = socket) do
    id = String.to_integer(id)
    document = Documents.get_document!(id, %{ document_versions: true })
    opts = state_opts(socket)
    {
      :noreply,
      socket
      |> Loaders.load_docubit_types(opts)
      |> Loaders.load_document(Documents.get_document!(id), opts)
      |> Loaders.load_document_versions(id, opts)
      |> Loaders.load_language_codes(opts)
      |> Loaders.load_pages(opts)
      |> Loaders.load_processes(opts)
      |> Loaders.load_files(opts)
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
      |> assign(:img_path, Routes.static_path(socket, "/images/"))
    }
  end
  def handle_params(_, _, socket), do: { :noreply, socket }

  def render_body(document_version) do
    Docubit.renderer(document_version.body).render(
      [
        docubit: document_version.body
      ]
    )
  end

  def render_docubit(%{ docubits: [ _ | _ ] = docubits } = docubit) when is_list(docubits) do
    docubit.renderer.render(
      docubit,
      Enum.map(docubits, fn(d) -> render_docubit(d) end),
      :editor
    )
  end
  def render_docubit(%{ docubits: [ ]} = docubit) do
    docubit.renderer.render(
      docubit,
      [],
      :editor
    )
  end

  @impl true
  def handle_event("change-language", %{"language" => %{"id" => id}}, socket) do
    { :noreply, assign(socket, :current_language_code_id, String.to_integer(id)) }
  end
  def handle_event("change-document-version", %{"document_version" => %{"id" => id}}, socket) do
    { :noreply, assign_document_version(socket, String.to_integer(id)) }
  end
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
    opts =
      state_opts(socket)
      |> Keyword.put(:preloads, [
          :body,
          :docubits,
          :version,
          [ docubits: :content ],
          [ docubits: :file ],
          [ docubits: :through_annotation ],
          [ docubits: :through_step ],
          [ docubits: :docubit_type ],
          [ docubits: [ content: :content_versions ] ],
          [ docubits: [ content: :annotation ] ],
          [ docubits: [ content: [ content_versions: :version ]]]
        ])

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

  defp assign_document_version(socket, id) do
    document_version = default_document_version(socket, id)
    document = Map.put(socket.assigns.document, :document_version, document_version)
    socket
    |> assign(:document, document)
  end

  defp current_selections(socket) do
    process = Automation.list_processes(socket, state_opts(socket)) |> Enum.at(0)
    page = Web.list_pages(socket, state_opts(socket)) |> Enum.at(0)
    version = Projects.get_version!(socket.assigns.current_version_id, socket, state_opts(socket))

    socket
    |> assign(:current_page, page)
    |> assign(:current_process, process)
    |> assign(:current_version, version)
  end

  defp default_language_code_id(socket) do
    language_code_id =
      Users.get_team!(socket.assigns.current_team_id, socket, state_opts(socket))
      |> Map.get(:default_language_code_id)

    socket
    |> assign(:current_language_code_id, language_code_id)
  end

  defp default_document_version_id(socket, document_or_id) do
    default_document_version(socket, document_or_id)
    |> Map.get(:id)
  end
  defp default_document_version(_socket, %Document{} = document) do
    document.document_versions
    |> Enum.at(0)
  end
end

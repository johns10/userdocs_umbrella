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
  alias UserDocs.Documents.DocubitSetting
  alias UserDocs.Documents.Docubit.Context
  alias UserDocs.Web.Page
  alias UserDocs.Web.Annotation
  alias UserDocs.Media.File

  alias UserDocsWeb.Root
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.DocubitLive.Renderers.Base

  @impl true
  def mount(_params, session, socket) do
    opts =
      state_opts()
      |> Keyword.put(:types, [  Document, DocumentVersion, Page,
        Process, Content, ContentVersion, Step, LanguageCode, Annotation,
        Docubit, File, DocubitType ])

    {
      :ok,
      socket
      |> StateHandlers.initialize(opts)
      |> Root.authorize(session)
      |> Root.initialize()
      |> assign(:state_opts, state_opts())
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{ assigns: %{ auth_state: :logged_in }} = socket) do
    id = String.to_integer(id)
    document = Documents.get_document!(id, %{ document_versions: true })
    {
      :noreply,
      socket
      |> Loaders.load_docubit_types(state_opts())
      |> Loaders.load_document(Documents.get_document!(id), state_opts())
      |> Loaders.load_document_versions(id, state_opts())
      |> Loaders.load_language_codes(state_opts())
      |> Loaders.load_pages(state_opts())
      |> Loaders.load_processes(state_opts())
      |> Loaders.load_files(state_opts())
      |> Loaders.load_content(state_opts())
      |> Loaders.load_content_versions(state_opts())
      |> Loaders.load_steps(state_opts())
      |> current_selections()
      |> Loaders.load_annotations(state_opts())
      |> SelectLists.language_code(state_opts())
      |> prepare_document(document)
      |> default_language_code_id()
      |> (&(Loaders.load_docubits(&1, default_document_version_id(&1, document), state_opts()))).()
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

  def handle_info(n, s), do: Root.handle_info(n, s)

  defp prepare_document(socket, document) do
    assign(socket, :document, document)
  end

  defp prepare_document_version(socket, document_version_id) do
    opts =
      state_opts()
      |> Keyword.put(:preloads, [
          :body,
          :docubits,
          :version,
          [ body: :content ],
          [ body: :file ],
          [ body: :through_annotation ],
          [ body: :through_step ],
          [ body: :docubit_type ],
          [ body: [ content: :content_versions ] ],
          [ body: [ content: :annotation ] ],
          [ body: [ content: [ content_versions: :version ]]]
        ])

    document_version = Documents.get_document_version!(document_version_id, socket, opts)

    body =
      document_version.body
      |> Docubit.apply_context(%{ settings: %{} })
      |> prepare_docubit(socket)

    document_version = Map.put(document_version, :body, body)

    socket
    |> assign(:document_version, document_version)
  end

  def prepare_docubit(docubit, socket = %{ assigns: assigns }) do
    preloads = [
      :docubits,
      :docubit_type,
      [ docubits: :content ],
      [ docubits: :file ],
      [ docubits: :through_annotation ],
      [ docubits: :through_step ],
      [ docubits: :docubit_type ],
      [ docubits: [ content: :content_versions ] ],
      [ docubits: [ content: :annotation ] ],
    ]

    opts =
      state_opts()
      |> Keyword.put(:preloads, preloads)
      |> Keyword.put(:order, docubits: %{field: :order, order: :asc})

    preloaded_docubit =
      Documents.get_docubit!(docubit.id, socket, opts)

    docubits =
      preloaded_docubit.docubits
      |> Enum.map(
        fn(child_docubit) ->
          Docubit.apply_context(child_docubit, docubit.context)
          |> prepare_docubit(socket)
        end)

    Map.put(docubit, :docubits, docubits)
  end

  defp state_opts() do
    Defaults.state_opts
    |> Keyword.put(:location, :data)
  end

  defp assign_document_version(socket) do
    document_version = socket.assigns.document.document_versions |> Enum.at(0)
    document = Map.put(socket.assigns.document, :document_version, document_version)
    socket
    |> assign(:document, document)
  end
  defp assign_document_version(socket, id) do
    document_version = default_document_version(socket, id)
    document = Map.put(socket.assigns.document, :document_version, document_version)
    socket
    |> assign(:document, document)
  end

  defp current_selections(socket) do
    process = Automation.list_processes(socket, state_opts()) |> Enum.at(0)
    page = Web.list_pages(socket, state_opts()) |> Enum.at(0)
    version = Projects.get_version!(socket.assigns.current_version_id, socket, state_opts())

    socket
    |> assign(:current_page, page)
    |> assign(:current_process, process)
    |> assign(:current_version, version)
  end

  defp default_language_code_id(socket) do
    language_code_id =
      Users.get_team!(socket.assigns.current_team_id, socket, state_opts())
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
  defp default_document_version(socket, document_id) do
    socket.assigns.document.document_versions
    |> Enum.at(0)
  end
  defp document_version(document_versions, document_version_id) do
    document_versions
    |> Enum.filter(fn(dv) -> dv.id == document_version_id end)
    |> Enum.at(0)
  end
end

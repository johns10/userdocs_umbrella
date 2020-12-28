defmodule UserDocsWeb.DocumentLive.Editor do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  require Logger

  alias UserDocsWeb.DocumentLive.Loaders
  alias UserDocsWeb.DocumentLive.SelectLists

  alias UserDocs.Documents
  alias UserDocs.Automation
  alias UserDocs.Projects
  alias UserDocs.Media
  alias UserDocs.Web
  alias UserDocs.Users

  alias UserDocs.Automation.Process
  alias UserDocs.Automation.Step
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
  alias UserDocsWeb.DocubitLive.Dragging

  @allowed_step_types ["Full Screen Screenshot", "Element Screenshot", "Apply Annotation"]

  @impl true
  def mount(_params, session, socket) do
    opts =
      state_opts()
      |> Keyword.put(:types, [  Document, DocumentVersion, Page,
        Process, Content, ContentVersion, Step, LanguageCode, Annotation,
        Docubit, File, DocubitType ])

    {:ok,
      socket
      |> StateHandlers.initialize(opts)
      |> Root.authorize(session)
      |> Root.initialize()
      |> assign(:dragging, %{ type: nil, id: nil})
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{ assigns: %{ auth_state: :logged_in }} = socket) do
    IO.puts("Opening editor")
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
      |> SelectLists.process(state_opts())
      |> current_selections()
      |> SelectLists.page(state_opts())
      |> Loaders.load_annotations(state_opts())
      |> SelectLists.language_code(state_opts())
      |> prepare_document(document)
      |> default_language_code_id()
      |> (&(Loaders.load_docubits(&1, default_document_version_id(&1, document), state_opts()))).()
      |> (&(prepare_document_version(&1, default_document_version_id(&1, document)))).()
      |> SelectLists.versions(state_opts())
      |> StateHandlers.inspect(state_opts())
    }
  end
  def handle_params(_, _, socket), do: { :noreply, socket }

  def render_body(docubit) do
    IO.puts("Rendering body")
    result = render_docubit(docubit)
    result
  end

  def render_docubit(%{ docubits: [ _ | _ ] = docubits } = docubit) when is_list(docubits) do
    # IO.puts("Rendering docubits")
    docubit.renderer.render(
      docubit,
      Enum.map(docubits, fn(d) -> render_docubit(d) end),
      :editor
    )
  end
  def render_docubit(%{ docubits: [ ]} = docubit) do
    # IO.puts("Rendering docubit #{docubit.type_id}")
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
  def handle_event("editor_drag_start", %{ "type" => type, "id" => id}, socket) do
    IO.puts("Started dragging #{type}, id #{id} from editor panel")
    {
      :noreply,
      socket
      |> assign(:dragging, %{ type: type, id: id })
    }
  end
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  @impl true
  def handle_info({:create_docubit, %{ type: type, docubit: docubit }}, socket) do

    max_order =
      case docubit.docubits  do
        [] -> 0
        [ _ | _ ] = docubits -> docubits |> Enum.at(-1) |> Map.get(:order, nil)
      end

    docubit_type = Documents.get_docubit_type_by_name!(socket, type, state_opts())
    docubit_type_attrs = Map.take(docubit_type, DocubitType.__schema__(:fields))

    new_docubit_attrs = %{
      docubit_type: docubit_type_attrs,
      docubit_type_id: docubit_type.id,
      order: max_order + 1,
      docubit_id: docubit.id,
      document_version_id: socket.assigns.document_version.id,
      settings: docubit_type.context.settings
    }


    # Get the exising docubits and extract attrs.  There's a better way to do this.
    # Probably change to put_assoc
    docubits =
      docubit.docubits
      |> Enum.map(fn(d) -> Map.take(d, Docubit.__schema__(:fields)) end)
      |> List.insert_at(-1, new_docubit_attrs)

    # update the parent docubit with the new children, and broadcast it
    socket =
      case Documents.update_docubit(docubit, %{ docubits: docubits }) do
        { :ok, docubit } ->
          IO.puts("Created Docubit Successfully")
          # This probably isn't sustainable
          added_docubit = Enum.at(docubit.docubits, -1)
          UserDocsWeb.Endpoint.broadcast(Defaults.channel(socket), "create", added_docubit)
          socket
          |> put_flash(:info, "Document created successfully")
        { :error, changeset } ->
          put_flash(socket, :error, "Creating Docubit failed  #{inspect(changeset.errors)}")
      end

    { :noreply, socket }
  end
  def handle_info(%{topic: topic, event: event, payload: %Docubit{} = docubit}, socket) do
    IO.puts("Handling Docubit Subscription")
    { :noreply, _ } = Root.handle_info(%{ topic: topic, event: event, payload: docubit }, socket)
  end
  def handle_info(n, s), do: Root.handle_info(n, s)


  defp prepare_document(socket, document) do
    assign(socket, :document, document)
  end

  defp prepare_document_version(socket, document_version_id) do
    IO.puts("Preparing Document Version")
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
        ])

    document_version = Documents.get_document_version!(document_version_id, socket, opts)

    body =
      document_version.body
      |> Docubit.apply_context(%{ settings: %{} })

    document_version = Map.put(document_version, :body, body)

    socket
    |> assign(:document_version, document_version)
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
    IO.puts("default_language_code_id")
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

  defp channel(socket) do
    Defaults.channel(socket)
  end

  defp local_channel(socket) do
    "document-version-" <> Integer.to_string(socket.assigns.document_version)
  end

  defp process_steps(process_id, steps) when is_integer(process_id) do
    steps
    |> Enum.filter(fn(s) -> s.process_id == process_id end)
    |> Enum.filter(fn(s) -> s.step_type.name in @allowed_step_types end)
  end
  defp process_annotations(page_id, annotations) do
    IO.puts("Process annotations")
    annotations
    |> Enum.filter(fn(a) -> a.page_id == page_id end)
  end
  defp panel_content(_, content), do: content
end

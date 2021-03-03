defmodule UserDocsWeb.DocumentLive.Editor do
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
  alias UserDocs.Documents.DocubitType
  alias UserDocs.Documents.DocubitSetting
  alias UserDocs.Documents.Docubit.Context

  alias UserDocsWeb.Root
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.DocubitEditorLive
  alias UserDocsWeb.DocubitLive.Dragging

  @allowed_step_types ["Full Screen Screenshot", "Element Screenshot", "Apply Annotation"]

  @types [
    UserDocs.Automation.Process,
    UserDocs.Automation.Step,
    UserDocs.Documents.Content,
    UserDocs.Documents.ContentVersion,
    UserDocs.Documents.Docubit,
    UserDocs.Documents.DocubitType,
    UserDocs.Documents.Document,
    UserDocs.Documents.DocumentVersion,
    UserDocs.Documents.LanguageCode,
    UserDocs.Media.Screenshot,
    UserDocs.Projects.Version,
    UserDocs.Users.Team,
    UserDocs.Web.Annotation,
    UserDocs.Web.AnnotationType,
    UserDocs.Web.Page,
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
      |> assign(:dragging, %{ type: nil, id: nil})
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{ assigns: %{ auth_state: :logged_in }} = socket) do
    IO.puts("Opening editor")
    id = String.to_integer(id)
    document = Documents.get_document!(id, %{ document_versions: true })
    opts = socket.assigns.state_opts
    {
      :noreply,
      socket
      |> Loaders.load_annotation_types(opts)
      |> Loaders.load_docubit_types(opts)
      |> Loaders.load_document(Documents.get_document!(id), opts)
      |> Loaders.load_document_versions(id, opts)
      |> Loaders.load_language_codes(opts)
      |> Loaders.load_pages(opts)
      |> Loaders.load_processes(opts)
      |> Loaders.load_content(opts)
      |> Loaders.load_content_versions(opts)
      |> Loaders.load_steps(opts)
      |> UserDocsWeb.Loaders.versions()
      |> UserDocsWeb.Loaders.screenshots(opts)
      |> SelectLists.process(opts)
      |> current_selections()
      |> SelectLists.page(opts)
      |> Loaders.load_annotations(opts)
      |> SelectLists.language_code(opts)
      |> prepare_document(document)
      |> prepare_content()
      |> prepare_annotations()
      |> default_language_code_id()
      |> (&(Loaders.load_docubits(&1, default_document_version_id(&1, document), opts))).()
      |> (&(prepare_document_version(&1, default_document_version_id(&1, document)))).()
      |> SelectLists.versions(opts)
      |> assign(:channel, Defaults.channel(socket))
      |> assign(:img_path, Routes.static_path(socket, "/images/"))
      |> assign(:state_opts, opts)
      |> StateHandlers.inspect(opts)
    }
  end
  def handle_params(_, _, socket), do: { :noreply, socket }

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

    docubit_type = Documents.get_docubit_type_by_name!(socket, type, socket.assigns.state_opts)

    new_docubit_attrs = %{
      docubit_type: convert_docubit_type_struct_to_map(docubit_type),
      docubit_type_id: docubit_type.id,
      order: max_order + 1,
      docubit_id: docubit.id,
      document_version_id: socket.assigns.document_version.id,
      #settings: convert_settings_struct_to_map(docubit_type.context.settings)
    }

    # Get the exising docubits and extract attrs.  There's a better way to do this.
    # Probably change to put_assoc
    docubits =
      docubit.docubits
      |> Enum.map(fn(docubit) ->
          docubit
          |> Map.take(Docubit.__schema__(:fields))
          |> Map.put(:context, convert_context_struct_to_map(docubit.context))
          |> Map.put(:settings, convert_settings_struct_to_map(docubit.settings))
        end)
      |> List.insert_at(-1, new_docubit_attrs)

    # update the parent docubit with the new children, and broadcast it
    socket =
      case Documents.update_docubit(docubit, %{ docubits: docubits }) do
        { :ok, docubit } ->
          # This probably isn't sustainable
          added_docubit = Enum.at(docubit.docubits, -1)
          UserDocsWeb.Endpoint.broadcast(Defaults.channel(socket), "create", added_docubit)
          socket
          |> put_flash(:info, "Docubit created successfully")
        { :error, changeset } ->
          put_flash(socket, :error, "Creating Docubit failed  #{inspect(changeset.errors)}")
      end

    { :noreply, socket }
  end
  def handle_info(%{topic: _, event: _, payload: %{ objects: [ %ContentVersion{} | _ ]}} = sub_data, socket) do
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    { :noreply, prepare_content(socket) }
  end
  def handle_info(%{topic: _, event: _, payload: %Content{}} = sub_data, socket) do
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    { :noreply, prepare_content(socket) }
  end
  def handle_info(%{topic: topic, event: event, payload: %Docubit{} = docubit}, socket) do
    IO.puts("Handling Docubit Subscription")
    { :noreply, _ } = Root.handle_info(%{ topic: topic, event: event, payload: docubit }, socket)
  end
  def handle_info({ :close_all_dropdowns, exclude }, socket) do
    Enum.each(Documents.list_docubits(socket, socket.assigns.state_opts),
      fn(docubit) ->
        if docubit.id not in exclude do
          send_update(
            DocubitEditorLive,
            id: "docubit-editor-" <> Integer.to_string(docubit.id),
            close_all_dropdowns: true
          )
        end
      end
    )
    { :noreply, socket }
  end
  def handle_info(n, s), do: Root.handle_info(n, s)

  defp convert_docubit_type_struct_to_map(docubit_type) do
    docubit_type
    |> Map.take(DocubitType.__schema__(:fields))
    |> Map.put(:context, convert_context_struct_to_map(docubit_type.context))
  end

  defp convert_context_struct_to_map(context) do
    context
    |> Map.take(Context.__schema__(:fields))
    |> Map.put(:settings, convert_settings_struct_to_map(context.settings))
  end

  defp convert_settings_struct_to_map(nil), do: nil
  defp convert_settings_struct_to_map(settings) do
    settings
    |> Map.take(DocubitSetting.__schema__(:fields))
  end

  defp prepare_document(socket, document) do
    assign(socket, :document, document)
  end

  defp prepare_document_version(socket, document_version_id) do
    IO.puts("Preparing Document Version")
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:preloads, [
          :body,
          :docubits,
          :version,
          [ body: :content ],
          [ body: :screenshot ],
          [ body: :through_annotation ],
          [ body: :through_step ],
          [ body: :docubit_type ],
          [ body: [ content: :content_versions ] ],
          [ body: [ content: [ content_versions: :version ]]]
        ])

    document_version = Documents.get_document_version!(document_version_id, socket, opts)

    body =
      document_version.body
      |> Docubit.apply_context(%{ settings: %{} })

    document_version = Map.put(document_version, :body, body)

    socket
    |> assign(:document_version, document_version)
  end

  defp prepare_content(socket) do
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:preloads, [
        :content_versions,
        [ content_versions: :version ]
      ])

    socket
    |> assign(:content, Documents.list_content(socket, opts))
  end

  defp prepare_annotations(socket) do
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:preloads, [
        :content,
        :annotation_type,
        [ content: :content_versions ],
        [ content: [ content_versions: :version] ]
      ])

    socket
    |> assign(:annotations, Web.list_annotations(socket, opts))
  end

  defp assign_document_version(socket, id) do
    document_version = default_document_version(socket, id)
    document = Map.put(socket.assigns.document, :document_version, document_version)
    socket
    |> assign(:document, document)
  end

  defp current_selections(socket) do
    opts = socket.assigns.state_opts
    process = Automation.list_processes(socket, opts) |> Enum.at(0)
    page = Web.list_pages(socket, opts) |> Enum.at(0)

    socket
    |> assign(:current_page, page)
    |> assign(:current_process, process)
    |> assign_current_version()
  end

  defp assign_current_version(socket) do
    version =
      socket.assigns.current_version_id
      |> Projects.get_version!(socket, socket.assigns.state_opts)

    socket
    |> assign(:current_version, version)
  end

  defp default_language_code_id(socket) do
    IO.puts("default_language_code_id")
    language_code_id =
      Users.get_team!(socket.assigns.current_team_id, socket, socket.assigns.state_opts)
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
  defp default_document_version(socket, _document_id) do
    socket.assigns.document.document_versions
    |> Enum.at(0)
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

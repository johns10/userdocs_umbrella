defmodule UserDocsWeb.AnnotationLive.FormComponent do
  use UserDocsWeb, :live_component

  require Logger

  alias UserDocs.Web
  alias UserDocs.Users
  alias UserDocs.Documents
  alias UserDocs.Documents.Content
  alias UserDocs.Projects
  alias UserDocs.Users.User
  alias UserDocs.Documents.ContentVersion

  alias UserDocsWeb.DomainHelpers
  alias UserDocsWeb.LiveHelpers
  alias UserDocsWeb.Layout

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:enabled_fields, [])

    {:ok, socket}
  end


  @impl true
  def update(%{annotation: annotation} = assigns, socket) do
    changeset = Web.change_annotation(annotation)
    maybe_parent_id = current_page_id(assigns, changeset)

    annotation_id =
      try do
        annotation.id
      rescue
        _ -> nil
      end

      IO.puts("Updating annotation live form component for annotation #{annotation_id}")

    team = team(assigns, assigns.current_user.default_team_id)

    annotation_types = annotation_types(assigns)
    annotation_types_select_options =
      annotation_types
      |> DomainHelpers.select_list_temp(:name, false)

    contents = contents(assigns, team.id)
    content_select_options =
      contents
      |> DomainHelpers.select_list_temp(:name, true)

    current_content = current_content(assigns, annotation.content_id)

    current_version = current_version(annotation_id, assigns)
    versions_select_options =
      all_content_versions(contents, annotation.content_id, assigns)
      |> Enum.map(fn(cv) -> cv.version_id end)
      |> Enum.uniq()
      |> versions(assigns)
      |> DomainHelpers.select_list_temp(:name, false)

    content_versions = content_versions(assigns, current_content.id, current_version.id)
    content_versions_select_options =
      content_versions
      |> Enum.map(&{&1.language_code.code, &1.id})

    pages = pages(assigns, team.id)
    pages_select_options =
      pages
      |> DomainHelpers.select_list_temp(:name, false)

    enabled_fields =
      LiveHelpers.enabled_fields(annotation_types, changeset.data.annotation_type_id)

    # TODO FIX
    annotation_type_name =
      try do
        annotation.annotation_type.name
      rescue
        _ -> ""
      end

    auto_gen_name = automatic_name(assigns, annotation_type_name)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:annotation, annotation)
     |> assign(:changeset, changeset)
     |> assign(:enabled_fields, enabled_fields)
     |> assign(:read_only, LiveHelpers.read_only?(assigns))
     |> assign(:maybe_action, LiveHelpers.maybe_action(assigns))
     |> assign(:maybe_parent_id, maybe_parent_id)
     |> assign(:annotation_types_select_options, annotation_types_select_options)
     |> assign(:content_select_options, content_select_options)
     |> assign(:versions_select_options, versions_select_options)
     |> assign(:pages_select_options, pages_select_options)
     |> assign(:content_versions_select_options, content_versions_select_options)
     |> assign(:current_version, current_version)
     |> assign(:current_content, current_content)
     |> assign(:auto_gen_name, auto_gen_name)
    }
  end

  @impl true
  def handle_event("validate", %{"annotation" => annotation_params}, socket) do
    enabled_fields =
      LiveHelpers.enabled_fields(annotation_types(socket.assigns),
        annotation_params["annotation_type_id"])


    current_changes =
      socket.assigns.annotation
      |> Web.change_annotation(annotation_params)
      |> Map.put(:action, :validate)

    socket = handle_changes(current_changes.changes, socket)

    { status, current_annotation } =
      case Ecto.Changeset.apply_action(current_changes, :update) do
        { :ok, current_annotation } -> { :ok, current_annotation }
        { _, _ } -> { :nok, socket.assigns.current_annotation }
      end

    changeset =
      socket.assigns.annotation
      |> Web.change_annotation(annotation_params)
      |> Map.put(:action, :validate)

      socket =
        socket
        |> assign(:changeset, changeset)
        |> assign(:enabled_fields, enabled_fields)

    {:noreply, socket}
  end

  def handle_event("save", %{"annotation" => annotation_params}, socket) do
    save_annotation(socket, socket.assigns.action, annotation_params)
  end

  defp handle_changes(%{annotation_type_id: annotation_type_id}, socket) do
    IO.puts("Handling a change to step annotation id: #{annotation_type_id}")
    annotation_type_name =
      annotation_types(socket.assigns)
      |> Enum.filter(fn(at) -> at.id == annotation_type_id end)
      |> Enum.at(0)
      |> Map.get(:name)

    name = automatic_name(socket.assigns, annotation_type_name)

    assign(socket, :auto_gen_name, name)
  end

  defp handle_changes(%{content_id: content_id}, socket) do
    IO.puts("Handling a change to step content id: #{content_id}")
    socket
  end

  defp handle_changes(%{content_version_id: content_version_id}, socket) do
    IO.puts("Handling a change to step content version id: #{content_version_id}")
    socket
  end

  defp handle_changes(_params, socket) do
    IO.puts("No changes we need to respond to")
    socket
  end

  defp save_annotation(socket, :edit, annotation_params) do
    case Web.update_annotation(socket.assigns.annotation, annotation_params) do
      {:ok, _annotation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Annotation updated successfully")
         # |> LiveHelpers.maybe_push_redirect()
         |> push_patch(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_annotation(socket, :new, annotation_params) do
    case Web.create_annotation(annotation_params) do
      {:ok, _annotation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Annotation created successfully")
         # |> LiveHelpers.maybe_push_redirect()
         |> push_patch(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp current_page_id(assigns, changeset) do
    try do
      assigns.parent.id
    rescue
      KeyError -> changeset.data.page_id
    end
  end

  defp annotation_types(assigns) do
    try do
      assigns.select_lists.available_annotation_types
    rescue
      _ ->
        Logger.warn("AnnotationLive.FormComponent reverting to database for annotation types")
        Web.list_annotation_types()
    end
  end

  defp contents(assigns, team_id) do
    try do
      assigns.select_lists.available_content
    rescue
      _ ->
        Logger.warn("AnnotationLive.FormComponent reverting to database for list_content")
        Documents.list_content(%{content_versions: true}, %{team_id: team_id})
    end
  end

  defp current_content(_, nil) do
    %Content{}
  end

  defp current_content(assigns, content_id) do
    try do
      assigns.select_lists.available_content
      |> Enum.filter(fn(c) -> c.id == content_id end)
      |> Enum.at(0)
    rescue
      _ ->
        Logger.warn("AnnotationLive.FormComponent reverting to database for individual content")
        Documents.get_content!(content_id)
    end
  end

  defp all_content_versions(_, nil, assigns) do
    try do
      assigns.select_lists.available_content_versions
    rescue
      _ ->
        Logger.warn("AnnotationLive.FormComponent reverting to database for all content versions")
        Documents.list_content_versions(%{language_code: true}, %{})
    end
  end
  defp all_content_versions(contents, content_id, _assigns) when is_integer(content_id) do
    contents
    |> Enum.filter(fn(c) -> c.id == content_id end)
    |> Enum.at(0)
    |> Map.get(:content_versions)
  end

  def automatic_name(assigns, annotation_type_name) do
    IO.puts("Automatic name for element")
    label =
      try do
        assigns.current_step.annotation.label
      rescue
        _ -> IO.inspect("FAIL")
      end
    element_name =
      try do
        assigns.related_element_name
      rescue
        _ -> ""
      end

    label <> ": "
    <> annotation_type_name <> " "
    <> element_name
  end

  # TODO: Probably busted, check
  defp content_versions(assigns, content_id, version_id) do
    try do
      assigns.select_lists.available_content_versions
      |> Enum.filter(fn(cv) -> cv.content_id == content_id end)
      |> Enum.filter(fn(cv) -> cv.version_id == version_id end)
    rescue
      _ ->
        Logger.warn("AnnotationLive.FormComponent reverting to database for content versions")
        Documents.list_content_versions(%{language_code: true}, %{content_id: content_id, version_id: version_id})
    end
  end

  defp versions(version_ids, assigns) do
    try do
      assigns.select_lists.available_versions
      |> Enum.filter(fn(v) -> v.id in version_ids end)
    rescue
      _ ->
        Logger.warn("AnnotationLive.FormComponent reverting to database for versions in #{version_ids}")
        Projects.list_versions(%{}, %{version_ids: version_ids})
    end
  end

  defp pages(assigns, team_id) do
    try do
      assigns.select_lists.available_pages
    rescue
      _ ->
        Logger.warn("AnnotationLive.FormComponent reverting to database for pages")
        Web.list_pages(%{}, %{team_id: team_id})
    end
  end

  defp team(assigns, team_id) do
    try do
      assigns.current_team
    rescue
      _ ->
        Logger.warn("AnnotationLive.FormComponent reverting to database for team")
        Users.get_team!(team_id)
    end
  end

  defp current_version(_, %{ current_version: current_version }) do
    current_version
  end
  defp current_version(annotation_id, _) do
    Logger.warn("AnnotationLive.FormComponent reverting to database for current_version")
    Projects.get_annotation_version!(annotation_id)
  end
end

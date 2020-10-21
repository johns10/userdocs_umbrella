defmodule UserDocsWeb.StepLive.FormComponent do
  use UserDocsWeb, :live_component

  require Logger

  alias UserDocsWeb.LiveHelpers
  alias UserDocsWeb.DomainHelpers
  alias UserDocsWeb.Layout

  alias UserDocs.Automation
  alias UserDocs.Documents
  alias UserDocs.Web
  alias UserDocs.Users
  alias UserDocs.Projects

  alias UserDocs.Web.Annotation

  alias UserDocs.Documents.Content
  alias UserDocs.Documents.ContentVersion

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:enabled_fields, [])
      |> assign(:current_url_reference, nil)
      |> assign(:final_url_reference, nil)
      |> assign(:current_page_id, nil)
      |> assign(:available_elements, [])
      |> assign(:available_annotations, [])
      |> assign(:enabled_annotation_fields, [])
      |> assign(:element_subform_disabled, false)
      |> assign(:annotation_subform_disabled, false)
      |> assign(:content_subform_disabled, false)
      |> assign(:auto_gen_annotation_name, "")

    {:ok, socket}
  end

  @impl true
  def update(%{step: step} = assigns, socket) do
    changeset = Automation.change_step(step)

    step_id = case assigns.action do
      :new -> nil
      :edit -> step.id
    end

    step_annotation_content_id = case step.annotation do
      nil -> nil
      %Web.Annotation{} -> step.annotation.content_id
      _ -> nil
    end

    team = team(assigns, step_id)
    current_version = current_version(assigns, step_id)

    # Get the version ID we're looking for
    version_id = version_id(assigns, step)

    # something
    steps = steps(assigns, step.process_id)
    page_id = page_id(assigns, step, steps)

    # Get the object lists we need for select lists
    step_types = step_types(assigns)
    step_type_select_options =
      step_types
      |> DomainHelpers.select_list_temp(:name, false)

    annotation_types = annotation_types(assigns)
    annotation_types_select_options =
      annotation_types
      |> DomainHelpers.select_list_temp(:name, false)

    language_codes = language_codes(assigns)
    language_codes_select_options =
      language_codes
      |> DomainHelpers.select_list_temp(:code, false)

    annotations = annotations(assigns, page_id)
    annotations_select_options =
      annotations
      |> DomainHelpers.select_list_temp(:name, false)

    processes = processes(assigns, version_id)
    processes_select_options =
      processes
      |> DomainHelpers.select_list_temp(:name, false)

    pages = pages(assigns, version_id)
    pages_select_options =
      pages
      |> DomainHelpers.select_list_temp(:name, false)

    elements = elements(assigns, page_id)
    elements_select_options =
      elements
      |> DomainHelpers.select_list_temp(:name, false)

    strategies = strategies(assigns)
    strategies_select_options =
      strategies
      |> DomainHelpers.select_list_temp(:name, false)

    enabled_fields =
      LiveHelpers.enabled_fields(
        step_types,
        changeset.data.step_type_id
      )

    contents = contents(assigns, team.id)
    contents_select_options =
      contents
      |> DomainHelpers.select_list_temp(:name, true)

    current_content = current_content(assigns, step_annotation_content_id)

    content_versions = content_versions(assigns, current_content.id, current_version.id)

    versions_select_options =
      all_content_versions(contents, step_annotation_content_id)
      |> Enum.map(fn(cv) -> cv.version_id end)
      |> Enum.uniq()
      |> versions(assigns)
      |> DomainHelpers.select_list_temp(:name, false)

    annotation_type_id =
      case changeset.data.annotation do
        nil -> nil
        %Ecto.Association.NotLoaded{} -> nil
        _ -> changeset.data.annotation.annotation_type_id
      end

    enabled_annotation_fields =
      LiveHelpers.enabled_fields(
        annotation_types,
        annotation_type_id
      )

    url_reference = url_reference(
      socket.assigns.current_url_reference || "",
      changeset.changes[:page_reference] || "",
      changeset.data.page_reference || ""
    )

    # TODO FIX
    step_type_name =
      try do
        step.step_type.name
      rescue
        _ -> ""
      end

    annotation_type_name =
      try do
        annotation_types
        |> Enum.filter(fn(at) -> at.id == annotation_type_id end)
        |> Enum.at(0)
        |> Map.get(:name)
      rescue
        _ -> ""
      end

    element_name =
      try do
        step.element.name
      rescue
        _ -> ""
      end

    auto_gen_name = automatic_name(step)
    auto_gen_annotation_name =
      UserDocsWeb.AnnotationLive.FormComponent.automatic_name(socket.assigns, annotation_type_name)
      <> element_name

    {:ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:current_step, step)
      |> assign(:current_version, current_version)
      |> assign(:current_content, current_content)
      |> assign(:enabled_fields, enabled_fields)
      |> assign(:read_only, LiveHelpers.read_only?(assigns))
      |> assign(:maybe_action, LiveHelpers.maybe_action(assigns))
      |> assign(:final_url_reference, url_reference)
      |> assign(:step_types, step_types)
      |> assign(:annotation_types, annotation_types)
      |> assign(:contents, contents)
      |> assign(:content_versions, content_versions)
      |> assign(:language_codes_select_options, language_codes_select_options)
      |> assign(:versions_select_options, versions_select_options)
      |> assign(:contents_select_options, contents_select_options)
      |> assign(:annotation_types_select_options, annotation_types_select_options)
      |> assign(:step_type_select_options, step_type_select_options)
      |> assign(:processes_select_options, processes_select_options)
      |> assign(:annotations_select_options, annotations_select_options)
      |> assign(:elements_select_options, elements_select_options)
      |> assign(:pages_select_options, pages_select_options)
      |> assign(:strategies_select_options, strategies_select_options)
      |> parent_id()
      |> assign(:enabled_annotation_fields, enabled_annotation_fields)
      |> assign(:selected_process_id, step.process_id)
      |> assign(:selected_page_id, page_id)
      |> assign(:selected_annotation_id, step.annotation_id)
      |> assign(:selected_element_id, step.element_id)
      |> assign(:element_subform_id, subform_id("element", "step",
          changeset.data.id, changeset.data.element))
      |> assign(:annotation_subform_id, subform_id("annotation", "step",
          changeset.data.id, changeset.data.element))
      |> assign(:auto_gen_name, auto_gen_name)
      |> assign(:auto_gen_annotation_name, auto_gen_annotation_name)
    }
  end

  @spec url_reference(charlist, charlist, charlist) :: :page | :url
  def url_reference("page", _, _), do: :page
  def url_reference("url", _, _), do: :url
  def url_reference(_, "page", _), do: :page
  def url_reference(_, "url", _), do: :url
  def url_reference(_, _, "page"), do: :page
  def url_reference(_, _, "url"), do: :url
  def url_reference(_current, _changes, _data), do: :page


  @impl true
  def handle_event("validate", %{"step" => step_params}, socket) do
    IO.puts("Validating")

    current_changes =
      socket.assigns.current_step
      |> Automation.change_step(step_params)
      |> Map.put(:action, :validate)

    socket = handle_changes(current_changes.changes, socket)

    { status, current_step } =
      case Ecto.Changeset.apply_action(current_changes, :update) do
        { :ok, current_step } -> { :ok, current_step }
        { _, _ } -> { :nok, socket.assigns.current_step }
      end

    changeset =
      socket.assigns.step
      |> Automation.change_step(step_params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:current_step, current_step)
    {:noreply, socket}
  end

  def handle_event("save", %{"step" => step_params}, socket) do
    step_params = maybe_selected_page(step_params, socket)
    save_step(socket, socket.assigns.action, step_params)
  end

  def maybe_selected_page(params = %{ "page_reference" => "page", "page_id" => page_id }, socket) do
    url =
      pages(socket.assigns, socket.assigns.current_version.id)
      |> Enum.filter(fn(p) -> p.id == String.to_integer(page_id) end)
      |> Enum.at(0)
      |> Map.get(:url)

    Map.put(params, "url", url)
  end
  def maybe_selected_page(state, _), do: state

  def handle_event("toggle_url_mode", %{"arg" => arg}, socket) do
    socket = assign(socket, :current_url_reference, arg)
    url_reference = url_reference(
      socket.assigns.current_url_reference || "",
      socket.assigns.changeset.changes[:page_reference] || "",
      socket.assigns.changeset.data.page_reference || ""
    )
    socket = assign(socket, :final_url_reference, url_reference)

    {:noreply, socket}
  end

  def handle_event("remove-content-version", %{"remove" => remove_id}, socket) do
    IO.puts("Removing Content Version #{remove_id} <- id")
    content_versions =
      socket.assigns.changeset.changes.annotation.changes.content.changes.content_versions
      |> Enum.reject(fn %{data: data, changes: changes} ->
        Map.get(changes, :temp_id, data.temp_id) == remove_id
      end)

    changeset = maybe_replace_content_changeset(
      socket.assigns.changeset,
      socket.assigns.current_step,
      content_versions
    )

    { _status, current_step } =
      case Ecto.Changeset.apply_action(changeset, :update) do
        { :ok, current_step } -> { :ok, current_step }
        { _, _ } -> { :nok, socket.assigns.current_step }
      end

      {
        :noreply,
        socket
        |> assign(changeset: changeset)
        |> assign(:current_step, current_step)
      }
  end

  # TODO: Jesus christ, what a massive pain in the ass.  Fix this bullshit.
  def handle_event("add-content-version", _, socket) do
    existing_content_versions =
      try do
        socket.assigns.changeset.changes.annotation.changes.content.changes.content_versions
      rescue
        _ ->
          socket.assigns.current_step.annotation.content.content_versions
          |> Enum.map(&Documents.change_content_version(&1))
      end

    content_versions =
      existing_content_versions
      |> Enum.concat([Documents.change_content_version(%ContentVersion{
          temp_id: UserDocs.ID.temp_id(),
          content_id: socket.assigns.current_step.annotation.content.id,
          version_id: socket.assigns.current_version.id,
          body: ""
        })])

    changeset = maybe_replace_content_changeset(
      socket.assigns.changeset,
      socket.assigns.current_step,
      content_versions
    )

    { _status, current_step } =
      case Ecto.Changeset.apply_action(changeset, :update) do
        { :ok, current_step } -> { :ok, current_step }
        { _, _ } -> { :nok, socket.assigns.current_step }
      end

    {
      :noreply,
      socket
      |> assign(changeset: changeset)
      |> assign(:current_step, current_step)
    }
  end

  def handle_event("new-element", _, socket) do
    IO.puts("Creating New Element")
    {
      :noreply,
      socket
    }
  end

  defp save_step(socket, :edit, step_params) do
    case Automation.update_step(socket.assigns.step, step_params) do
      {:ok, _step} ->
        {:noreply,
         socket
         |> put_flash(:info, "Step updated successfully")
         |> LiveHelpers.maybe_push_redirect()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_step(socket, :new, step_params) do
    case Automation.create_step(step_params) do
      {:ok, _step} ->
        {:noreply,
         socket
         |> put_flash(:info, "Step created successfully")
         |> LiveHelpers.maybe_push_redirect()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete-content-version", %{"id" => id}, socket) do
    content_version = Documents.get_content_version!(id)
    {:ok, _} = Documents.delete_content_version(content_version)

    {:noreply, socket}
  end

  defp maybe_replace_content_changeset(changeset, step, content_versions) do
    content_changeset =
      try do
        changeset.changes.annotation.changes.content
        |> Ecto.Changeset.put_assoc(:content_versions, content_versions)
      rescue
        KeyError ->
          Logger.warn("Putting Content Versions in the content changeset failed")
          Documents.change_content(step.annotation.content, %{})
          |> Ecto.Changeset.put_assoc(:content_versions, content_versions)
      end

    annotation_changeset =
      try do
        changeset.changes.annotation
        |> Ecto.Changeset.put_assoc(:content, content_changeset)
      rescue
        KeyError ->
          Logger.warn("Putting Content in the Annotation changeset failed")
          Web.change_annotation(step.annotation, %{})
          |> Ecto.Changeset.put_assoc(:content, content_changeset)
      end

    try do
      changeset
      |> Ecto.Changeset.put_assoc(:annotation, annotation_changeset)
    rescue
      KeyError ->
        Logger.warn("Putting the Annotation in the Step changeset failed")
        Automation.change_step(step, %{})
        |> Ecto.Changeset.put_assoc(:annotation, annotation_changeset)
    end
  end

  @spec maybe_parent_id(atom | map) :: any
  def maybe_parent_id(assigns) do
    DomainHelpers.maybe_parent_id(assigns, :process_id)
  end
  defp handle_changes(%{process_id: process_id}, socket) do
    IO.puts("Handling a change to process id: #{process_id}")
    socket
  end

  defp handle_changes(%{step_type_id: step_type_id}, socket) do
    IO.puts("Handling a change to step type id: #{step_type_id}")
    enabled_fields =
      LiveHelpers.enabled_fields(
        socket.assigns.step_types,
        step_type_id
      )

    current_step =
      step_types(socket.assigns)
      |> Enum.filter(fn(s) -> s.id == step_type_id end)
      |> Enum.at(0)
      |> Map.put(socket.assigns.current_step, :step_type)

    name = automatic_name(current_step)

    socket
    |> assign(:enabled_fields, enabled_fields)
    |> assign(:auto_gen_name, name)
  end

  defp handle_changes(%{page_id: page_id}, socket) do
    IO.puts("Handling a change to page id: #{page_id}")
    elements = elements(socket.assigns, page_id)
    elements_select_options =
      DomainHelpers.select_list_temp(elements, :name, false)

    socket
    |> assign(:elements, elements)
    |> assign(:elements_select_options, elements_select_options)
  end

  defp handle_changes(%{annotation_id: annotation_id}, socket) do
    IO.puts("Handling a change to annotation id: #{annotation_id}")
    socket
    |> assign(:selected_annotation_id, annotation_id)
    |> assign(:annotation_subform_disabled, true)
  end

  defp handle_changes(%{element_id: element_id}, socket) do
    IO.puts("Handling a change to element id: #{element_id}")
    socket
    |> assign(:selected_element_id, element_id)
  end

  defp handle_changes(%{annotation: %{changes: %{annotation_type_id: annotation_type_id}}}, socket) do
    IO.puts("Handling a change to annotation type id in the step form: #{annotation_type_id}")

    enabled_annotation_fields =
      LiveHelpers.enabled_fields(
        socket.assigns.annotation_types,
        annotation_type_id
      )

    annotation_type_name =
      socket.assigns.annotation_types
      |> Enum.filter(fn(at) -> at.id == annotation_type_id end)
      |> Enum.at(0)
      |> Map.get(:name)

    annotation_name =
      UserDocsWeb.AnnotationLive.FormComponent.automatic_name(socket.assigns, annotation_type_name)
      <> socket.assigns.current_step.element.name

    socket
    |> assign(:enabled_annotation_fields, enabled_annotation_fields)
    |> assign(:auto_gen_annotation_name, annotation_name)
  end

  defp handle_changes(%{annotation: %{changes: %{content_id: content_id}}}, socket) do
    # In this function we'll fetch the versions, and the content versions for the selected
    # content id, and pick the current content version as the first item in content_versions
    IO.puts("Handling a change to content id in the annotation: #{content_id}")
    current_content = current_content(socket.assigns, content_id)

    versions_select_options =
      all_content_versions(socket.assigns.contents, content_id)
      |> Enum.map(fn(cv) -> cv.version_id end)
      |> Enum.uniq()
      |> versions(socket.assigns)
      |> DomainHelpers.select_list_temp(:name, false)

    content_versions = content_versions(socket.assigns, current_content.id, socket.assigns.current_version.id)

    socket
    |> assign(:versions_select_options, versions_select_options)
    |> assign(:content_versions, content_versions)
  end

  defp handle_changes(%{annotation: %{changes: %{content_version_id: content_version_id}}}, socket) do
    IO.puts("Handling a change to content version id in the annotation: #{content_version_id}")
    socket
  end

  defp handle_changes(params, socket) do
    IO.puts("No changes we need to respond to on the step form")
    socket
  end


  def form_field_id(assigns, f, form_field) do
    Layout.form_field_id(assigns.maybe_action, f, form_field,
      "process", assigns.maybe_parent_id)
  end

  def subform_id(type, parent_type, parent_id, element = %Web.Element{}) do
    parent_type <> "_"
    <> Integer.to_string(parent_id) <> "_"
    <> type <> "_"
    <> Integer.to_string(element.id) <> "_"
    <> "embedded_form"
  end
  def subform_id(type, parent_type, nil, _) do
    parent_type <> "_"
    <> "empty_"
    <> type
    <> "_embedded_form"
  end
  def subform_id(type, parent_type, parent_id, _) do
    parent_type <> "_"
    <> Integer.to_string(parent_id) <> "_"
    <> "empty_"
    <> type
    <> "_embedded_form"
  end

  def parent_id(socket) do
    assign(socket, :maybe_parent_id, DomainHelpers.maybe_parent_id(socket.assigns, :page_id))
  end

  def automatic_name(%{ step_type: %{ name: "Apply Annotation" = name } } = current_step) do
    Logger.debug("Automatic name generation: #{name}")

    annotation_name = current_step.annotation.name || ""

    Integer.to_string(current_step.order) <> ". "
    <> current_step.step_type.name <> " "
    <> annotation_name
  end
  def automatic_name(%{ step_type: %{ name: "Navigate" = name } } = current_step) do
    Logger.debug("Automatic name generation: #{name}")
    try do
      current_step.step_type.name <> " to "
      <> current_step.page.name
    rescue
      _ -> ""
    end
  end
  def automatic_name(%{ step_type: %{ name: "Set Size Explicit" = name } } = current_step) do
    Logger.debug("Automatic name generation: #{name}")
    current_step.step_type.name <> " to "
    <> Integer.to_string(current_step.width)
    <> "X"
    <> Integer.to_string(current_step.height)
  end
  def automatic_name(%{ step_type: %{ name: "Element Screenshot" = name } } = current_step) do
    Logger.debug("Automatic name generation: #{name}")
    current_step.step_type.name <> " of "
    <> current_step.element.name
  end
  def automatic_name(%{ step_type: %{ name: "Clear Annotations" = name } } = current_step) do
    Logger.debug("Automatic name generation: #{name}")
    name
  end
  def automatic_name(%{ step_type: %{ name: name } } = current_step) do
    Logger.warn("Unhandled automatic name generation: #{name}")
    name
  end
  def automatic_name(_) do
    Logger.warn("Generating an automatic name with no current_step")
    ""
  end

  defp team(assigns, step_id) do
    try do
      assigns.current_team
    rescue
      _ -> Users.get_step_team!(step_id)
    end
  end

  defp step_types(assigns) do
    try do
      assigns.select_lists.available_step_types
    rescue
      KeyError -> Automation.list_step_types()
      _ -> IO.puts("Couldn't get step types")
    end
  end

  defp annotation_types(assigns) do
    try do
      assigns.select_lists.available_annotation_types
    rescue
      KeyError ->
        Logger.warn("StepLive.FormComponent reverting to database for annotation types")
        Web.list_annotation_types()
    end
  end

  defp language_codes(assigns) do
    try do
      assigns.select_lists.language_codes
    rescue
      KeyError ->
        Logger.warn("StepLive.FormComponent reverting to database for language codes")
        Documents.list_language_codes()
      _ -> IO.puts("Couldn't get language codes")
    end
  end

  defp versions(version_ids, assigns) do
    try do
      assigns.select_lists.available_versions
    rescue
      _ ->
        Logger.warn("StepLive.FormComponent reverting to database for Versions")
        Projects.list_versions(%{}, %{version_ids: version_ids})
    end
  end

  defp steps(assigns, process_id) do
    try do
      assigns.parent.steps
    rescue
      KeyError -> Automation.list_steps(%{step_type: true}, %{process_id: process_id})
    end
  end

  defp elements(assigns, page_id) when is_integer(page_id) do
    try do
      assigns.select_lists.available_pages
      |> Enum.filter(fn(p) -> p.id == page_id end)
      |> Enum.at(0)
      |> Map.get(:elements)
    rescue
      KeyError ->
        Logger.warn("StepLive.FormComponent reverting to database for Elements")
        Web.list_elements(%{strategy: true}, %{page_id: page_id})
    end
  end
  defp elements(assigns, _) do
    Logger.warn("Fetching elements for a nil page ID")
    try do
      assigns.select_lists.elements
    rescue
      KeyError -> []
    end
  end

  defp annotations(assigns, page_id) when is_integer(page_id) do
    try do
      assigns.select_lists.available_pages
      |> Enum.filter(fn(p) -> p.id == page_id end)
      |> Enum.at(0)
      |> Map.get(:annotations)
    rescue
      KeyError -> Web.list_annotations(%{}, %{page_id: page_id})
    end
  end
  defp annotations(assigns, _) do
    # Logger.warn("Fetching annotations for a nil page ID")
    try do
      assigns.select_lists.available_annotations
    rescue
      KeyError -> []
    end
  end

  # TODO: Filter this
  defp pages(assigns, version_id) do
    try do
      assigns.select_lists.available_pages
    rescue
      KeyError -> Web.list_pages(
        %{elements: true, annotations: true},
        %{version_id: version_id})
    end
  end

  defp contents(assigns, team_id) do
    try do
      assigns.select_lists.available_content
    rescue
      KeyError ->
        Logger.warn("StepLive.FormComponent querying content")
        Documents.list_content(%{content_versions: true}, %{team_id: team_id})
    end
  end

  defp page_id(assigns, step = %{page_id: page_id, process_id: process_id}, steps) do
    most_recent_navigated_to_page_id(step, steps)
  end
  defp page_id(assigns, %{page_id: page_id}, _) do
    IO.puts("Getting page")
    try do
      assigns.select_lists.available_pages
      |> Enum.filter(fn(p) -> p.id == page_id end)
      |> Enum.at(0)
      |> Map.get(:id)
    rescue
      KeyError ->
        Web.get_page!(page_id)
        |> Map.get(:id)
    end
  end

  defp processes(assigns, version_id) do
    try do
      assigns.select_lists.available_processes
    rescue
      KeyError -> Automation.list_processes(%{}, %{version_id: version_id})
    end
  end

  defp strategies(assigns) do
    try do
      assigns.select_lists.strategies
    rescue
      KeyError ->
        Logger.warn("StepLive.FormComponent querying strategies")
        Web.list_strategies()
    end
  end

  defp version_id(assigns, step) do
    try do
      assigns.parent.id
    rescue
      KeyError -> Map.get(Automation.get_process!(step.process_id), :version_id)
    end
  end

  defp most_recent_navigated_to_page_id(step, steps) do
    try do
      steps
      |> Enum.filter(fn(s) -> s.step_type.name == "Navigate" end)
      |> Enum.filter(fn(s) -> s.order < step.order  end)
      |> Enum.max_by(fn(s) -> s.order || 0 end)
      |> Map.get(:page_id)
    rescue
      EmptyError -> None
      _ -> None
    end
  end

  defp current_version(assigns, step_id) do
    try do
      assigns.current_version
    rescue
      _ -> Projects.get_step_version!(step_id)
    end
  end

  defp all_content_versions(_, nil), do: []
  defp all_content_versions(contents, content_id) when is_integer(content_id) do
    contents
    |> Enum.filter(fn(c) -> c.id == content_id end)
    |> Enum.at(0)
    |> Map.get(:content_versions)
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
        Logger.warn("StepLive.FormComponent querying individual content")
        Documents.get_content!(content_id)
    end
  end

  defp content_versions(assigns, content_id, version_id) do
    try do
      assigns.select_lists.available_content_versions
      |> Enum.filter(fn(cv) -> cv.content_id == content_id end)
      |> Enum.filter(fn(cv) -> cv.version_id == version_id end)
    rescue
      _ ->
        Logger.warn("StepLive.FormComponent querying content versions")
        Documents.list_content_versions(%{language_code: true}, %{content_id: content_id, version_id: version_id})
    end
  end
end

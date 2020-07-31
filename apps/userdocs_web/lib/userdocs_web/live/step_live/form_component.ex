defmodule UserDocsWeb.StepLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.LiveHelpers
  alias UserDocsWeb.DomainHelpers
  alias UserDocsWeb.Layout

  alias UserDocs.Automation

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

    {:ok, socket}
  end

  @impl true
  def update(%{step: step} = assigns, socket) do
    changeset = Automation.change_step(step)
    maybe_parent_id = DomainHelpers.maybe_parent_id(assigns, :page_id)
    enabled_fields =
      LiveHelpers.enabled_fields(
        assigns.select_lists.available_step_types,
        changeset.data.step_type_id
      )

    annotation_type_id =
      case changeset.data.annotation do
        nil -> nil
        %Ecto.Association.NotLoaded{} -> nil
        _ -> changeset.data.annotation.annotation_type_id
      end

    enabled_annotation_fields =
      LiveHelpers.enabled_fields(
        assigns.select_lists.available_annotation_types,
        annotation_type_id
      )

    url_reference = url_reference(
      socket.assigns.current_url_reference || "",
      changeset.changes[:page_reference] || "",
      changeset.data.page_reference || ""
    )

    socket =
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:enabled_fields, enabled_fields)
      |> assign(:read_only, LiveHelpers.read_only?(assigns))
      |> assign(:maybe_action, LiveHelpers.maybe_action(assigns))
      |> assign(:final_url_reference, url_reference)
      |> assign(:maybe_parent_id, maybe_parent_id)
      |> assign(:available_elements, available_elements(assigns, changeset))
      |> assign(:available_annotations, available_annotations(assigns, changeset))
      |> assign(:enabled_annotation_fields, enabled_annotation_fields)

    {:ok, socket}
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

    enabled_fields =
      LiveHelpers.enabled_fields(
        socket.assigns.select_lists.available_step_types,
        step_params["step_type_id"]
      )

    enabled_annotation_fields =
      LiveHelpers.enabled_fields(
        socket.assigns.select_lists.available_annotation_types,
        step_params["annotation"]["annotation_type_id"]
      )

    changeset =
      socket.assigns.step
      |> Automation.change_step(step_params)
      |> Map.put(:action, :validate)

    {changeset, socket} = change_router({changeset, socket})

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:enabled_fields, enabled_fields)
      |> assign(:enabled_annotation_fields, enabled_annotation_fields)

    {:noreply, socket}
  end

  def handle_event("save", %{"step" => step_params}, socket) do
    save_step(socket, socket.assigns.action, step_params)
  end

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

  @spec current_element(list, charlist) :: UserDocs.Web.Element.t()
  def current_element(_, ""), do: %UserDocs.Web.Page{}
  def current_element(_, nil), do: %UserDocs.Web.Page{}
  def current_element(%Ecto.Association.NotLoaded{}, _), do: %UserDocs.Web.Page{}
  def current_element(elements, element_id) do
    elements
      |> Enum.filter(fn(e) -> e.id == String.to_integer(element_id) end)
      |> Enum.at(0)
  end

  def available_processes(assigns) do
    DomainHelpers.maybe_select_list(assigns, :available_processes)
  end


  def available_pages(assigns) do
    DomainHelpers.maybe_select_list(assigns, :available_pages)
  end

  @spec maybe_parent_id(atom | map) :: any
  def maybe_parent_id(assigns) do
    DomainHelpers.maybe_parent_id(assigns, :process_id)
  end

  def form_field_id(assigns, f, form_field) do
    Layout.form_field_id(assigns.maybe_action, f, form_field,
      "process", assigns.maybe_parent_id)
  end

  def available_elements(_assigns, %{ data: %{page_id: nil}, changes: %{page_id: nil}}) do
    _log_string = "Available Elements for change and data to a nil page ID"
    []
  end
  def available_elements(_assigns, %{ changes: %{page_id: nil}}) do
    _log_string = "Available Elements for a change to a nil page ID"
    []
  end
  def available_elements(_assigns, %{ data: %{page_id: nil}}) do
    _log_string = "Available Elements for data with a nil page ID"
    []
  end
  def available_elements(assigns, %{ changes: %{page_id: page_id}}) do
    _log_string = "Available Elements where the changes has page_id: "
    <> Integer.to_string(page_id)
    available_elements(assigns, page_id)
  end
  def available_elements(assigns, %{ data: %{ page_id: page_id}}) do
    _log_string = "Available Elements where the data has page id "
    <> Integer.to_string(page_id)
    available_elements(assigns, page_id)
  end
  def available_elements(_,  %{}), do: []
  def available_elements(_, nil), do: []
  def available_elements(assigns, page_id) when is_integer(page_id) do
    assigns.select_lists.available_pages
    |> Enum.filter(fn(p) -> p.id == page_id end)
    |> Enum.at(0)
    |> Map.get(:elements)
    |> DomainHelpers.select_list()
  end

  def available_annotations(_assigns, %{ data: %{page_id: nil}, changes: %{page_id: nil}}) do
    _log_string = "Available Annotations for change and data to a nil page ID"
    []
  end
  def available_annotations(_assigns, %{ changes: %{page_id: nil}}) do
    _log_string = "Available Annotations for a change to a nil page ID"
    []
  end
  def available_annotations(_assigns, %{ data: %{page_id: nil}}) do
    _log_string = "Available Annotations for data with a nil page ID"
    []
  end
  def available_annotations(assigns, %{ changes: %{page_id: page_id}}) do
    _log_string = "Available Annotations where the changes has page_id: "
    <> Integer.to_string(page_id)
    available_annotations(assigns, page_id)
  end
  def available_annotations(assigns, %{ data: %{ page_id: page_id}}) do
    _log_string = "Available Annotations where the data has page id "
    <> Integer.to_string(page_id)
    available_annotations(assigns, page_id)
  end
  def available_annotations(_,  %{}), do: []
  def available_annotations(_, nil), do: []
  def available_annotations(assigns, page_id) when is_integer(page_id) do
    assigns.select_lists.available_pages
    |> Enum.filter(fn(p) -> p.id == page_id end)
    |> Enum.at(0)
    |> Map.get(:annotations)
    |> DomainHelpers.select_list()
  end

  def change_router({changeset, socket}) do
    _log_string = "Detected a changeset with changes"
    {changeset, socket} =
      {changeset, socket}
      |> page_change()
      |> element_change()
      |> annotation_change()

    {changeset, socket}
  end

  defp page_change({changeset = %{changes: %{page_id: page_id}}, socket}) do
    { changeset, page_change(page_id, socket)}
  end
  defp page_change({changeset = %{data: %{page_id: page_id}}, socket}) do
    { changeset, page_change(page_id, socket)}
  end
  defp page_change(page_id, socket) when is_integer(page_id) do
    _log_string = "Page ID changed to: "
    <> Integer.to_string(page_id)
    socket
    |> assign(:available_elements, available_elements(socket.assigns, page_id))
    |> assign(:available_annotations, available_annotations(socket.assigns, page_id))
  end
  defp page_change(nil, socket) do
    _log_string = "Page ID changed to nil"
    socket
    |> assign(:available_elements, [])
    |> assign(:available_elements, [])
  end
  defp page_change(_, socket), do: socket

  defp element_change({changeset, socket}) do
    { changeset, socket }
  end

  defp annotation_change({changeset, socket}) do
    { changeset, socket }
  end

  @spec subform_id(binary, binary, integer, atom | %{id: integer}) :: binary
  def subform_id(type, parent_type, parent_id, nil) do
    parent_type <> "_"
    <> Integer.to_string(parent_id) <> "_"
    <> "empty_"
    <> type
    <> "_embedded_form"
  end
  def subform_id(type, parent_type, parent_id, element) do
    parent_type <> "_"
    <> Integer.to_string(parent_id) <> "_"
    <> type <> "_"
    <> Integer.to_string(element.id) <> "_"
    <> "embedded_form"
  end
end

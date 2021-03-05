defmodule UserDocsWeb.StepLive.FormComponent do
  use UserDocsWeb, :live_component

  require Logger

  alias UserDocsWeb.AnnotationLive
  alias UserDocsWeb.ElementLive
  alias UserDocsWeb.PageLive
  alias UserDocsWeb.ID
  alias UserDocsWeb.Layout

  alias UserDocs.Automation
  alias UserDocs.Documents
  alias UserDocs.Web
  alias UserDocs.Web.Annotation
  alias UserDocs.Helpers

  @impl true
  def update(%{step: step} = assigns, socket) do
    changeset =
      case Map.get(socket.assigns, :changeset, nil) do
        nil -> Automation.change_step(step)
        changeset ->
          Automation.change_step(step)
          |> Map.put(:changes, Map.get(changeset, :changes))
      end

    step_type_id = Map.get(step, :step_type_id, nil)

    annotation_type_id =
      step
      |> Map.get(:annotation, nil)
      |> case do
        nil -> nil
        annotation -> Map.get(annotation, :annotation_type_id, nil)
      end

    enabled_step_fields =
      UserDocsWeb.LiveHelpers.enabled_fields(
        assigns.data.step_types,
        step_type_id
      )

    enabled_annotation_fields =
      UserDocsWeb.LiveHelpers.enabled_fields(
        assigns.data.annotation_types,
        annotation_type_id
      )

    element_field_ids =
      ElementLive.FormComponent.field_ids(step.element)

    page_field_ids =
      PageLive.FormComponent.field_ids(step.page)

    annotation_field_ids =
      AnnotationLive.FormComponent.field_ids(step.annotation)

    step_field_ids =
      field_ids(step)
      |> Map.put(:page, page_field_ids)
      |> Map.put(:element, element_field_ids)
      |> Map.put(:annotation, annotation_field_ids)

    form_ids =
      %{}
      |> Map.put(:prefix, ID.prefix(step))
      |> Map.put(:element, nested_form_id(step, step.element))
      |> Map.put(:page, nested_form_id(step, step.page))
      |> Map.put(:annotation, nested_form_id(step, step.annotation))

    select_lists =
      assigns.select_lists
      |> Map.put(:annotations, Helpers.select_list(assigns.data.annotations, :name, true))
      |> Map.put(:elements, elements_select(assigns, step.page_id || assigns.default_page_id))

    nested_element_expanded =
      case { Ecto.Changeset.get_field(changeset, :element_id), Ecto.Changeset.get_change(changeset, :element) } do
        { nil, nil } -> false
        { _, _ } -> true
      end

    nested_annotation_expanded =
      case { Ecto.Changeset.get_field(changeset, :annotation_id), Ecto.Changeset.get_change(changeset, :annotation) } do
        { nil, nil } -> false
        { _, _ } -> true
      end
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:current_object, step)
      |> assign(:enabled_step_fields, enabled_step_fields)
      |> assign(:enabled_annotation_fields, enabled_annotation_fields)
      |> assign(:nested_element_expanded, nested_element_expanded)
      |> assign(:nested_annotation_expanded, nested_annotation_expanded)
      |> assign(:field_ids, step_field_ids)
      |> assign(:form_ids, form_ids)
      |> assign(:select_lists, select_lists)
      |> assign(:disable_element_fields, false)
      |> assign(:disable_annotation_fields, false)
      |> assign(:state_opts, assigns.state_opts)
    }
  end

  @impl true
  def handle_event("validate", %{"step" => step_params}, socket) do
    changeset =
      Automation.change_step(socket.assigns.step, step_params)

    { changeset, socket } =
      case Ecto.Changeset.get_change(changeset, :element_id, nil) do
        nil -> { changeset, socket }
        element_id ->
          { :ok, step } = Automation.update_step(socket.assigns.step, %{ element_id: element_id })
          element = Web.get_element!(element_id)
          step = Map.put(step, :element, element)
          {
            Automation.change_step(step, Map.delete(step_params, "element")),
            socket
            |> assign(:step, step)
          }
      end

    { changeset, socket } =
      case Ecto.Changeset.get_change(changeset, :annotation_id, nil) do
        nil -> { changeset, socket }
        annotation_id ->
          { :ok, step } = Automation.update_step(socket.assigns.step, %{ annotation_id: annotation_id })
          opts = Keyword.put(socket.assigns.state_opts, :preloads, [ :content, :annotation_type ])
          annotation = Web.get_annotation!(annotation_id, socket, opts)
          step = Map.put(step, :annotation, annotation)
          {
            Automation.change_step(step, Map.delete(step_params, "annotation")),
            socket
            |> assign(:step, step)
          }
      end

    { changeset, socket } =
      case Ecto.Changeset.get_change(changeset, :page_id, nil) do
        nil -> { changeset, socket }
        page_id ->
          { :ok, step } = Automation.update_step(socket.assigns.step, %{ page_id: page_id })
          page = Web.get_page!(page_id)
          step = Map.put(step, :page, page)
          select_lists =
            socket.assigns.select_lists
            |> Map.put(:elements, elements_select(socket.assigns, page_id))
          {
            step
            |> Automation.change_step(Map.delete(step_params, "page")),
            socket
            |> assign(:step, step)
            |> assign(:select_lists, select_lists)
          }
      end

    { changeset, socket } =
      case Ecto.Changeset.get_change(changeset, :annotation, :no_change) do
        :no_change -> { changeset, socket }
        annotation_changeset ->
          case Ecto.Changeset.get_change(annotation_changeset, :content_id, :no_change) do
            :no_change -> { changeset, socket }
            content_id ->
              step = update_step_content(socket.assigns.step, content_id)
              {
                update_changeset_for_content_change(step, step_params),
                assign(socket, :step, step)
              }
          end
      end

    enabled_step_fields =
      case socket.assigns.action do
        :new -> []
        :edit ->
          UserDocsWeb.LiveHelpers.enabled_fields(
            Automation.list_step_types(socket, socket.assigns.state_opts),
            Ecto.Changeset.get_field(changeset, :step_type_id)
          )
      end

    enabled_annotation_fields =
      case socket.assigns.action do
        :new -> []
        :edit ->
          annotation_type_id =
            changeset
            |> Ecto.Changeset.get_field(:annotation)
            |> case do
              nil -> nil
              %Annotation{} = annotation -> Map.get(annotation, :annotation_type_id)
            end

          UserDocsWeb.LiveHelpers.enabled_fields(
            Web.list_annotation_types(socket, socket.assigns.state_opts),
            annotation_type_id
          )
    end


    {
      :noreply,
      socket
      |> assign(:changeset, changeset)
      |> assign(:enabled_step_fields, enabled_step_fields)
      |> assign(:enabled_annotation_fields, enabled_annotation_fields)
    }
  end

  @impl true
  def handle_event("save", %{"step" => step_params}, socket) do
    save_step(socket, socket.assigns.action, step_params)
  end

  @impl true
  def handle_event("test_selector", %{ "element-id" => element_id }, socket) do
    element_id = String.to_integer(element_id)
    element = UserDocs.Web.get_element!(element_id, %{ strategy: true }, %{}, socket.assigns.data)

    payload =  %{
      type: "step",
      payload: %{
        process: %{
          steps: [
            %{
              id: 0,
              selector: element.selector,
              strategy: element.strategy,
              step_type: %{
                name: "Test Selector"
              }
            }
           ],
        },
        element_id: socket.assigns.id,
        status: "not_started",
        active_annotations: []
      }
    }

    {
      :noreply,
      socket
      |> push_event("test_selector", payload)
    }
  end
  def handle_event("new-element", _, socket) do
    changeset = Automation.new_step_element(
      socket.assigns.step, socket.assigns.changeset)

    {
      :noreply,
      socket
      |> assign(:changeset, changeset)
      |> assign(:step, changeset.data)
    }
  end
  def handle_event("new-page", _, socket) do
    changeset = Automation.new_step_page(
      socket.assigns.step, socket.assigns.changeset)

    {
      :noreply,
      socket
      |> assign(:changeset, changeset)
      |> assign(:step, changeset.data)
    }
  end

  def handle_event("new-annotation", _, socket) do
    changeset = Automation.new_step_annotation(
      socket.assigns.step, socket.assigns.changeset)

    {
      :noreply,
      socket
      |> assign(:changeset, changeset)
      |> assign(:step, changeset.data)
    }
  end

  def handle_event("new-content", %{ "annotation-id" => _ }, socket) do
    annotation = socket.assigns.step.annotation

    { :ok, new_annotation } =
      annotation
      |> UserDocs.Web.update_annotation(%{ content_id: nil })

    cleared_annotation = Map.put(new_annotation, :content, nil)

    old_annotation_changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.get_change(:annotation, UserDocs.Web.change_annotation(%Web.Annotation{}))

    annotation_params =
      old_annotation_changeset.params
      |> Map.put("content", "")
      |> Map.put("content_id", "")

    new_annotation_changeset =
      cleared_annotation
      |> UserDocs.Web.change_annotation(annotation_params)

    new_step =
      socket.assigns.step
      |> Map.put(:annotation, cleared_annotation)

    new_changeset =
      new_step
      |> Automation.Step.changeset(socket.assigns.changeset.params)
      |> Ecto.Changeset.put_change(:annotation, new_annotation_changeset)

    {
      :noreply,
      socket
      |> assign(:step, new_step)
      |> assign(:changeset, new_changeset)
    }
  end
  def handle_event("delete", %{"id" => id}, socket) do
    step = Automation.get_step!(String.to_integer(id))
    {:ok, deleted_step } = Automation.delete_step(step)
    send(self(), { :broadcast, "delete", deleted_step })
    {:noreply, socket}
  end

  defp save_step(socket, :edit, step_params) do
    case Automation.update_step(socket.assigns.step, remove_empty_associations(step_params)) do
      {:ok, step} ->
        send(self(), {:close_modal, to: socket.assigns.return_to })
        Automation.handle_step_broadcast(step, "update")
        {
          :noreply,
          socket
          |> put_flash(:info, "Step updated successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_step(socket, :new, step_params) do
    # recent_navigated_to_page(process, step, assigns)
    case Automation.create_step(step_params) do
      {:ok, step} ->
        send(self(), {:close_modal, to: socket.assigns.return_to })
        Automation.handle_step_broadcast(step, "create")
        {
          :noreply,
          socket
          |> put_flash(:info, "Step created successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp remove_empty_associations(params) do
    params
    |> maybe_remove_empty_element()
    |> maybe_remove_empty_annotation()
  end

  defp maybe_remove_empty_element(
    %{
      "element" => %{
        "id" => "",
        "name" => "",
        "order" => "",
        "selector" => "",
        "strategy_id" => ""
      } = element_params
    } = step_params
  ) do
    element_params =
      element_params
      |> Map.put("page_id", "")

    Map.put(step_params, "annotation", element_params)
  end
  defp maybe_remove_empty_element(params), do: params

  defp maybe_remove_empty_annotation(
    %{
      "annotation" =>
      %{
        "annotation_type_id" => "",
        "color" => "",
        "content_id" => "",
        "font_size" => "",
        "id" => "",
        "label" => "",
        "size" => "",
        "thickness" => "",
        "x_offset" => "",
        "x_orientation" => "",
        "y_offset" => "",
        "y_orientation" => ""
      } = annotation_params
    } = step_params
  ) do
    annotation_params =
      annotation_params
      |> Map.put("name", "")
      |> Map.put("step_id", "")

    Map.put(step_params, "annotation", annotation_params)
  end
  defp maybe_remove_empty_annotation(params), do: params

  def expand(socket, key) do
    socket
    |> assign(key, not Map.get(socket.assigns, key))
  end

  def field_ids(step = %Automation.Step{}) do
    %{}
    |> Map.put(:name, ID.form_field(step, :name))
    |> Map.put(:process_id, ID.form_field(step, :process_id))
    |> Map.put(:order, ID.form_field(step, :order))
    |> Map.put(:step_type_id, ID.form_field(step, :step_type_id))
    |> Map.put(:element_id, ID.form_field(step, :element_id))
    |> Map.put(:annotation_id, ID.form_field(step, :annotation_id))
    |> Map.put(:page_reference_url, ID.form_field(step, :page_reference_url))
    |> Map.put(:page_reference_page, ID.form_field(step, :page_reference_page))
    |> Map.put(:page_id, ID.form_field(step, :page_id))
    |> Map.put(:url, ID.form_field(step, :url))
    |> Map.put(:text, ID.form_field(step, :text))
    |> Map.put(:width, ID.form_field(step, :width))
    |> Map.put(:height, ID.form_field(step, :height))
  end

  def nested_form_id(step = %Automation.Step{}, element = %Web.Element{}) do
    ID.nested_form(step, element)
  end
  def nested_form_id(step = %Automation.Step{}, page = %Web.Page{}) do
    ID.nested_form(step, page)
  end
  def nested_form_id(step = %Automation.Step{}, annotation = %Web.Annotation{}) do
    ID.nested_form(step, annotation)
  end
  def nested_form_id(_, _), do: ""

  def page_reference(changeset) do
    Ecto.Changeset.get_field(changeset, :page_reference, nil)
  end

  def name(changeset) do
    Ecto.Changeset.get_field(changeset, :name, nil)
  end

  def elements_select(%{ state_opts: state_opts } = socket, page_id) do
    opts = Keyword.put(state_opts, :filter, { :page_id, page_id })
    Web.list_elements(socket, opts)
    |> Helpers.select_list(:name, true)
  end

  def update_step_content(%Automation.Step{ annotation: nil } = step, _), do: step
  def update_step_content(%Automation.Step{ annotation: annotation } = step, content_id) do
    { :ok, annotation } =
      Web.update_annotation(annotation, %{ content_id: content_id })
    content = content_or_nil(content_id)
    new_annotation = Map.put(annotation, :content, content)
    Map.put(step, :annotation, new_annotation)
  end

  def content_or_nil(nil), do: nil
  def content_or_nil(id), do: Documents.get_content!(id)

  def update_changeset_for_content_change(step, params) do
    { _, params } = Kernel.pop_in(params, [ "annotation", "content" ])
    { _, params } = Kernel.pop_in(params, [ "annotation", "content_id" ])
    Automation.change_step(step, params)
  end
end

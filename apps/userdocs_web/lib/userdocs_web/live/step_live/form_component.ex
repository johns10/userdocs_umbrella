defmodule UserDocsWeb.StepLive.FormComponent do
  use UserDocsWeb, :live_component

  require Logger

  alias UserDocsWeb.AnnotationLive
  alias UserDocsWeb.ElementLive
  alias UserDocsWeb.PageLive
  alias UserDocsWeb.ID
  alias UserDocsWeb.Layout
  alias UserDocsWeb.StepLive.FormComponent.Helpers

  alias UserDocs.Automation
  alias UserDocs.Automation.Step
  alias UserDocs.Documents
  alias UserDocs.Web
  alias UserDocs.Web.Element
  alias UserDocs.Web.Annotation

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
      |> Map.put(:elements, elements_select(assigns, step.page_id || assigns.default_page_id))
      |> Map.put(:annotations, annotations_select(assigns, step.page_id || assigns.default_page_id))

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
      |> assign(:state_opts, assigns.state_opts)
      |> assign(:last_step, assigns.step)
    }
  end

  @impl true
  def handle_event("validate", %{"step" => step_params}, socket) do
    last_step = socket.assigns.last_step
    nested_changeset =
      socket.assigns.step
      |> Automation.change_nested_step(last_step, step_params, socket, :validate)
      |> Map.put(:action, :validate)

    last_change = Step.changeset(last_step, step_params)

    changeset =
      with changeset <- Step.fields_changeset(socket.assigns.step, step_params),
        changeset <- Changeset.maybe_replace_page_params(changeset, last_change, socket),
        changeset <- Changeset.maybe_replace_annotation_params(changeset, last_change, socket),
        changeset <- Changeset.maybe_replace_element_params(changeset, last_change, socket),
        changeset <- Changeset.maybe_replace_content_params(changeset, last_change, socket),
        changeset <- Automation.Step.assoc_changeset(changeset),
        changeset <- Automation.Step.names_changeset(changeset),
        changeset <- Map.put(changeset, :action, :validate),
        changeset <- Ecto.Changeset.validate_required(changeset, [:order])
      do
        changeset
      else
        _ -> raise("Fail")
      end

    enabled_step_fields = Helpers.enabled_step_fields(socket, changeset)
    enabled_annotation_fields = Helpers.enabled_annotation_fields(socket, changeset)

    socket =
      case Ecto.Changeset.apply_action(nested_changeset, :update) do
        { :ok, step } ->
          assign(socket, :last_step, step)
        { :error, changeset } ->
          Logger.error("Last Step Changeset #{changeset.data.id} failed to update")
          socket
      end

    {
      :noreply,
      socket
      |> assign(:enabled_step_fields, enabled_step_fields)
      |> assign(:enabled_annotation_fields, enabled_annotation_fields)
      |> assign(:changeset, changeset)
    }

  end

  @impl true
  def handle_event("save", %{"step" => step_params}, socket) do
    save_step(socket, socket.assigns.action, step_params)
  end

  @impl true
  def handle_event("test_selector", %{ "element-id" => element_id }, socket) do
    element_id = String.to_integer(element_id)
    element = UserDocs.Web.get_element!(element_id, %{ strategy: true }, %{})

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
      |> assign(:new_element, true)
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
      |> assign(:new_annotation, true)
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

  defp save_step(socket, :edit, step_params) do
    step = socket.assigns.step
    last_step = socket.assigns.last_step
    changeset = Automation.change_step(step, step_params)

    case Automation.update_nested_step(step, last_step, step_params, socket, :update) do
      {:ok, step} ->
        opts = socket.assigns.state_opts |> Keyword.put(:action, :update)
        UserDocs.Subscription.broadcast_children(step, changeset, opts)
        send(self(), { :broadcast, "update", step })
        {
          :noreply,
          socket
          |> put_flash(:info, "Step updated successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_step(socket, :new, step_params) do
    order = step_params["order"]
    step_type = Automation.get_step_type!(step_params["step_type_id"])
    name = order <> ": " <> step_type.name
    case Automation.create_step(Map.put(step_params, "name", name)) do
      {:ok, step} ->
        send(self(), { :broadcast, "create", step })
        {
          :noreply,
          socket
          |> put_flash(:info, "Step created successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
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

  def elements_select(%{ state_opts: state_opts } = socket, page_id) do
    opts = Keyword.put(state_opts, :filter, { :page_id, page_id })
    Web.list_elements(socket, opts)
    |> UserDocs.Helpers.select_list(:name, true)
  end

  def annotations_select(%{ state_opts: state_opts } = socket, page_id) do
    opts = Keyword.put(state_opts, :filter, { :page_id, page_id })
    Web.list_annotations(socket, opts)
    |> UserDocs.Helpers.select_list(:name, true)
  end
end

defmodule UserDocsWeb.StepLive.FormComponent do
  use UserDocsWeb, :live_component

  require Logger

  alias UserDocsWeb.LiveHelpers

  alias UserDocsWeb.AnnotationLive
  alias UserDocsWeb.ElementLive
  alias UserDocsWeb.PageLive
  alias UserDocsWeb.ID

  alias UserDocsWeb.Layout
  alias UserDocs.Automation
  alias UserDocs.Automation.Process.RecentPage
  alias UserDocs.Web
  alias UserDocs.Web.Page

  @impl true
  def update(%{step: step} = assigns, socket) do
    changeset = Automation.change_step(step)

    step_type_id =
      try do
        step.step_type_id
      rescue
        _ ->
          assigns.data.step_types
          |> Enum.at(0)
          |> Map.get(:id)
      end

    annotation_type_id =
      try do
        step.annotation.annotation_type_id
      rescue
        _ ->
          assigns.data.annotation_types
          |> Enum.at(0)
          |> Map.get(:id)
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

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:current_object, step)
      |> assign(:enabled_step_fields, enabled_step_fields)
      |> assign(:enabled_annotation_fields, enabled_annotation_fields)
      |> assign(:nested_element_expanded, false)
      |> assign(:nested_annotation_expanded, false)
      |> assign(:nested_annotation_content_expanded, false)
      |> assign(:field_ids, step_field_ids)
      |> assign(:form_ids, form_ids)
      |> assign(:default_page_id, recent_navigated_to_page(assigns.parent, step, assigns))
    }
  end

  @impl true
  def handle_event("validate", %{"step" => step_params}, socket) do
    changeset =
      Automation.change_step_with_nested_data(
        socket.assigns.step, step_params, socket.assigns)

    step_type_id = Ecto.Changeset.get_field(changeset, :step_type_id)

    annotation_type_id =
      case Ecto.Changeset.get_field(changeset, :annotation, nil) do
        nil -> nil
        annotation -> annotation.annotation_type_id
      end

    enabled_step_fields =
      UserDocsWeb.LiveHelpers.enabled_fields(
        Automation.list_step_types(socket, socket.assigns.state_opts),
        step_type_id
      )

    enabled_annotation_fields =
      UserDocsWeb.LiveHelpers.enabled_fields(
        Web.list_annotation_types(socket, socket.assigns.state_opts),
        annotation_type_id
      )

    {
      :noreply,
      socket
      |> assign(:changeset, changeset)
      |> assign(:step, changeset.data)
      |> assign(:enabled_step_fields, enabled_step_fields)
      |> assign(:enabled_annotation_fields, enabled_annotation_fields)
    }
  end

  @impl true
  def handle_event("save", %{"step" => step_params}, socket) do
    save_step(socket, socket.assigns.action, step_params)
  end

  @impl true
  def handle_event("expand-annotation", _, socket), do: {:noreply, expand(socket, :nested_annotation_expanded)}
  def handle_event("expand-element", _, socket), do: {:noreply, expand(socket, :nested_element_expanded)}
  def handle_event("expand-annotation-content", _, socket), do: {:noreply, expand(socket, :nested_annotation_content_expanded)}

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
  def handle_event("delete", %{"id" => id}, socket) do
    step = Automation.get_step!(String.to_integer(id))
    {:ok, deleted_step } = Automation.delete_step(step)
    send(self(), { :broadcast, "delete", deleted_step })
    {:noreply, socket}
  end

  defp save_step(socket, :edit, step_params) do
    case Automation.update_step(socket.assigns.step, remove_empty_associations(step_params)) do
      {:ok, step} ->
        send(self(), { :broadcast, "update", step })
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
        send(self(), { :broadcast, "create", step })
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

  def recent_navigated_to_page(process, step, assigns) do
    case RecentPage.get(process, step, Web.list_pages(assigns, assigns.state_opts)) do
      %Page{} = page -> Map.get(page, :id, nil)
      nil -> ""
    end
  end

  def page_reference(changeset) do
    Ecto.Changeset.get_field(changeset, :page_reference, nil)
  end

  def name(changeset) do
    Ecto.Changeset.get_field(changeset, :name, nil)
  end
end

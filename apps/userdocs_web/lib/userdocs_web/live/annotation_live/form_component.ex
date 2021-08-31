defmodule UserDocsWeb.AnnotationLive.FormComponent do
  use UserDocsWeb, :live_slime_component

  require Logger

  alias UserDocsWeb.Layout

  alias UserDocs.Web

  @impl true
  def render(assigns) do
    ~L"""
    = form = form_for @changeset, "#",
      id: @id,
      phx_target: @myself.cid,
      phx_change: "validate",
      phx_submit: "save"

      = render_fields(assigns, form)

      = submit "Save", phx_disable_with: "Saving...", class: "button is-link"

    </form>
    """
  end

  def render_fields(assigns, form, prefix \\ "") do
    ~L"""
    = hidden_input(form, :name, [ value: Ecto.Changeset.get_field(@changeset, :name, "") ])
    .field.is-grouped
      = Layout.select_input(form, :page_id, @select_lists.pages_select,
        [ selected: form.data.page_id || "" ], "control")
      = Layout.select_input(form, :annotation_type_id, @select_lists.annotation_types,
        [ placeholder: form.data.annotation_type_id || "None" ], "control")

    .field.is-grouped.is-grouped-multiline
      = if @last_step_form.annotation.label_enabled do
        div.control style="width: 15%;"
          = label form, :label, class: "label"
          div.control
            = text_input form, :label, class: "input", type: "text"

      = if @last_step_form.annotation.size_enabled do
        div.control style="width: 15%;"
          = label form, :size, class: "label"
          div.control
            = number_input form, :size, class: "input", type: "text"

      = if @last_step_form.annotation.x_offset_enabled do
        div.control style="width: 15%;"
          = label form, :x_offset, class: "label"
          div.control
            = number_input form, :x_offset, class: "input", type: "text"

      = if @last_step_form.annotation.y_offset_enabled do
        div.control style="width: 15%;"
          = label form, :y_offset, class: "label"
          div.control
            = number_input form, :y_offset, class: "input", type: "text"

      = if @last_step_form.annotation.font_size_enabled do
        div.control style="width: 15%;"
          = label form, :font_size, class: "label"
            div.control
              = text_input form, :font_size, class: "input", type: "text"

      = if @last_step_form.annotation.x_orientation_enabled do
        = Layout.select_input(form, :x_orientation,
          [{"None", ""}, { "Right", "R" }, {"Middle", "M"}, { "Left", "L" }],
          [ placeholder: form.data.x_orientation || "" ], "control")

      = if @last_step_form.annotation.y_orientation_enabled do
        = Layout.select_input(form, :y_orientation,
          [{"None", ""}, { "Top", "T" }, {"Middle", "M"}, { "Bottom", "B" }],
          [ placeholder: form.data.y_orientation || "" ], "control")

      = if @last_step_form.annotation.color_enabled do
        = Layout.text_input(form, :color, [], "control")

      = if @last_step_form.annotation.thickness_enabled do
        div.control style="width: 15%;"
          = label form, :thickness, class: "label"
          div.control
            = text_input form, :thickness, class: "input", type: "text"

    """
  end

  @impl true
  def update(%{annotation: annotation} = assigns, socket) do
    changeset = Web.change_annotation(annotation)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"annotation" => annotation_params}, socket) do
    changeset =
      socket.assigns.annotation
      |> Web.change_annotation(annotation_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"annotation" => annotation_params}, socket) do
    save_annotation(socket, socket.assigns.action, annotation_params)
  end

  defp save_annotation(socket, :edit, annotation_params) do
    case Web.update_annotation(socket.assigns.annotation, annotation_params) do
      {:ok, _annotation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Annotation updated successfully")
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
         |> push_patch(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

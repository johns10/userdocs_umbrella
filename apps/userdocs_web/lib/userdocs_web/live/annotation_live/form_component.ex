defmodule UserDocsWeb.AnnotationLive.FormComponent do
  use UserDocsWeb, :live_slime_component

  require Logger

  alias UserDocsWeb.Layout

  alias UserDocs.Annotations
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

    .grid.grid-cols-4.gap-2

      = label form, :page_id, class: "label mb-0"
      .col-span-3
        = select form, :page_id, @select_lists.pages_select,
          class: "flex-1 select select-sm select-bordered mb-0",
          selected: form.data.page_id || ""
      = error_tag form, :page_id

      = label form, :annotation_type_id, "Ann. Type", class: "label mb-0"
      .col-span-3
        = select form, :annotation_type_id, @select_lists.annotation_types,
          class: "flex-1 select select-sm select-bordered mb-0",
          selected: form.data.annotation_type_id || "None"
      = error_tag form, :annotation_type_id

      = if @last_step_form.annotation.label_enabled do
        .form-control
          = label form, :label, class: "label mb-0"
          = text_input form, :label, type: "text", class: "input input-sm input-bordered mb-0"
          = error_tag form, :label

      = if @last_step_form.annotation.size_enabled do
        .form-control
          = label form, :size, class: "label mb-0"
          = number_input form, :size, type: "text", class: "input input-sm input-bordered mb-0"
          = error_tag form, :size

      = if @last_step_form.annotation.x_offset_enabled do
        .form-control
          = label form, :x_offset, class: "label mb-0"
          = number_input form, :x_offset, type: "text", class: "input input-sm input-bordered mb-0"
          = error_tag form, :x_offset

      = if @last_step_form.annotation.y_offset_enabled do
        .form-control
          = label form, :y_offset, class: "label mb-0"
          = number_input form, :y_offset, type: "text", class: "input input-sm input-bordered mb-0"
          = error_tag form, :y_offset

      = if @last_step_form.annotation.font_size_enabled do
        .form-control
          = label form, :font_size, class: "label mb-0"
          = text_input form, :font_size, type: "text", class: "input input-sm input-bordered mb-0"
          = error_tag form, :font_size

      = if @last_step_form.annotation.color_enabled do
        .form-control
          = label form, :color, class: "label mb-0"
          = text_input form, :color, type: "text", class: "input input-sm input-bordered mb-0"
          = error_tag form, :color

      = if @last_step_form.annotation.x_orientation_enabled do
        .form-control
          = label form, :x_orientation, class: "label pr-0 mb-0"
          = select form, :x_orientation,
            [{"None", ""}, {"Right", "R"}, {"Middle", "M"}, {"Left", "L"}],
            class: "flex-1 select select-sm select-bordered mb-0",
            placeholder: form.data.x_orientation || ""
          = error_tag form, :x_orientation

      = if @last_step_form.annotation.y_orientation_enabled do
        .form-control
          = label form, :y_orientation, class: "label pr-0 mb-0"
          = select form, :y_orientation,
            [{"None", ""}, {"Top", "T"}, {"Middle", "M"}, {"Bottom", "B"}],
            class: "flex-1 select select-sm select-bordered mb-0",
            placeholder: form.data.y_orientation || ""
          = error_tag form, :y_orientation

      = if @last_step_form.annotation.thickness_enabled do
        .form-control
          = label form, :thickness, class: "label mb-0"
          = text_input form, :thickness, type: "text", class: "input input-sm input-bordered mb-0"
          = error_tag form, :thickness
    """
  end

  @impl true
  def update(%{annotation: annotation} = assigns, socket) do
    changeset = Annotations.change_annotation(annotation)

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
      |> Annotations.change_annotation(annotation_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"annotation" => annotation_params}, socket) do
    save_annotation(socket, socket.assigns.action, annotation_params)
  end

  defp save_annotation(socket, :edit, annotation_params) do
    case Annotations.update_annotation(socket.assigns.annotation, annotation_params) do
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
    case Annotations.create_annotation(annotation_params) do
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

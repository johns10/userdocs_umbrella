defmodule UserDocsWeb.AnnotationLive.FormComponent do
  use UserDocsWeb, :live_component

  require Logger

  alias UserDocsWeb.Layout
  alias UserDocsWeb.ID

  alias UserDocs.Web

  def render(assigns) do
    ~L"""
      <%= form = form_for @changeset, "#",
        id: @id,
        phx_target: @myself.cid,
        phx_change: "validate",
        phx_submit: "save" %>

        <%= render_fields(assigns, form) %>

        <%= submit "Save", phx_disable_with: "Saving...", class: "button is-link" %>

      </form>
    """
  end

  def render_fields(assigns, form, prefix \\ "") do
    ~L"""
      <%= hidden_input(form, :id, [ value: form.data.id ]) %>

      <%= hidden_input(form, :name, [
        id: @field_ids.annotation.name,
        value: Ecto.Changeset.get_field(@changeset, :name, "")
      ]) %>

      <div class="field is-grouped">

        <%= Layout.select_input(form, :page_id, @select_lists.pages_select, [
          selected: form.data.page_id || @default_page_id || "",
          id: @field_ids.annotation.page_id,
        ], "control") %>

        <%= Layout.select_input(form, :annotation_type_id, @select_lists.annotation_types, [
            placeholder: form.data.annotation_type_id || "",
            id: ID.form_field(form.data, :annotation_type_id, prefix),
          ], "control") %>

      </div>
      <div class="field is-grouped is-grouped-multiline">

        <%= Layout.text_input(form, :label, [
          id: @field_ids.annotation.label,
          hidden: not("label" in @enabled_annotation_fields)
        ], "control") %>

        <%=
          Layout.select_input(form, :x_orientation,
            [{"None", ""}, { "Right", "R" }, {"Middle", "M"}, { "Left", "L" }], [
              placeholder: form.data.x_orientation || "",
              id: @field_ids.annotation.x_orientation,
              hidden: "x_orientation" not in @enabled_annotation_fields
            ], "control")
        %>

        <%=
          Layout.select_input(form, :y_orientation,
            [{"None", ""}, { "Top", "T" }, {"Middle", "M"}, { "Bottom", "B" }], [
              placeholder: form.data.y_orientation || "",
              id: @field_ids.annotation.y_orientation,
              hidden: not("y_orientation" in @enabled_annotation_fields),
            ], "control")
        %>

        <%= Layout.number_input(form, :size, [
          id: @field_ids.annotation.size,
          hidden: not("size" in @enabled_annotation_fields)
        ], "control") %>

        <%= Layout.text_input(form, :color, [
          id: @field_ids.annotation.color,
          hidden: not("color" in @enabled_annotation_fields)
        ], "control") %>

        <%= Layout.number_input(form, :thickness, [
          id: @field_ids.annotation.thickness,
          hidden: not("thickness" in @enabled_annotation_fields)
        ], "control") %>

        <%= Layout.number_input(form, :x_offset, [
          id: @field_ids.annotation.x_offset,
          hidden: not("x_offset" in @enabled_annotation_fields)
        ], "control") %>

        <%= Layout.number_input(form, :y_offset, [
          id: @field_ids.annotation.y_offset,
          hidden: not("y_offset" in @enabled_annotation_fields)
        ], "control") %>

        <%= Layout.text_input(form, [
          field_name: :font_size,
          id: @field_ids.annotation.font_size,
          hidden: not("font_size" in @enabled_annotation_fields)
        ]) %>

      </div>

      <%= label form, :content_id, class: "label" %>
      <div class="field is-horizontal">
        <div class="field-body">
          <div class="field has-addons">

            <%= Layout.new_item_button("new-content", [ button_class: :div ], "control") %>

            <%= Layout.select_input(form, :content_id, @select_lists.content,
              [
                value: form.data.content_id,
                id: @field_ids.annotation.content_id,
                label: false
              ]) %>

          </div>
        </div>
      </div>
    """
  end

  @impl true
  def update(%{annotation: annotation} = assigns, socket) do
    changeset = Web.change_annotation(annotation)

    form_ids =
      %{}
      |> Map.put(:content, ID.prefix(annotation))

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:field_ids, field_ids(annotation))
      |> assign(:form_ids, form_ids)
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

  def field_ids(annotation = %Web.Annotation{}) do
    %{}
    |> Map.put(:name, ID.form_field(annotation, :name))
    |> Map.put(:page_id, ID.form_field(annotation, :page_id))
    |> Map.put(:label, ID.form_field(annotation, :label))
    |> Map.put(:x_orientation, ID.form_field(annotation, :x_orientation))
    |> Map.put(:y_orientation, ID.form_field(annotation, :y_orientation))
    |> Map.put(:size, ID.form_field(annotation, :size))
    |> Map.put(:color, ID.form_field(annotation, :color))
    |> Map.put(:thickness, ID.form_field(annotation, :thickness))
    |> Map.put(:x_offset, ID.form_field(annotation, :x_offset))
    |> Map.put(:y_offset, ID.form_field(annotation, :y_offset))
    |> Map.put(:font_size, ID.form_field(annotation, :font_size))
    |> Map.put(:content_id, ID.form_field(annotation, :content_id))
  end
  def field_ids(_) do
    %{}
    |> Map.put(:name, "")
    |> Map.put(:page_id, "")
    |> Map.put(:label,  "")
    |> Map.put(:x_orientation, "")
    |> Map.put(:y_orientation, "")
    |> Map.put(:size, "")
    |> Map.put(:color, "")
    |> Map.put(:thickness, "")
    |> Map.put(:x_offset, "")
    |> Map.put(:y_offset, "")
    |> Map.put(:font_size, "")
    |> Map.put(:content_id, "")
  end
end

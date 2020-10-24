defmodule ProcessAdministratorWeb.AnnotationLive.FormComponent do
  use UserDocsWeb, :live_component

  require Logger

  alias ProcessAdministratorWeb.Layout
  alias ProcessAdministratorWeb.ContentLive
  alias ProcessAdministratorWeb.ID

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

        <div class="field is-grouped is-grouped-multiline">
          <div class="control">
          </div>
        </div>
      </form>
    """
  end

  def render_fields(assigns, form, prefix \\ "") do
    ~L"""
      <%= hidden_input(form, :name, [
        id: ID.form_field(form.data, :name, prefix),
        value: @current_object.annotation.name
      ]) %>

      <div class="field is-grouped">

        <%= Layout.select_input(form, :page_id, @select_lists.pages_select, [
          placeholder: @parent_id || "",
          id: ID.form_field(form.data, :page_id, prefix),
        ], "control") %>

        <%= Layout.select_input(form, :annotation_type_id, @select_lists.annotation_types, [
            placeholder: form.data.annotation_type_id || "",
            id: ID.form_field(form.data, :annotation_type_id, prefix),
          ], "control") %>

      </div>
      <div class="field is-grouped is-grouped-multiline">

        <%= Layout.text_input(form, :label, [
          id: ID.form_field(form.data, :label, prefix),
          hidden: not("label" in @enabled_annotation_fields)
        ], "control") %>

        <%=
          Layout.select_input(form, :x_orientation,
            [{ "Right", "R" }, {"Middle", "M"}, { "Left", "L" }], [
              placeholder: form.data.x_orientation || "",
              id: ID.form_field(form.data, :x_orientation, prefix),
              hidden: "x_orientation" not in @enabled_annotation_fields
            ], "control")
        %>

        <%=
          Layout.select_input(form, :y_orientation,
            [{ "Top", "T" }, {"Middle", "M"}, { "Bottom", "B" }], [
              placeholder: form.data.y_orientation || "",
              id: ID.form_field(form.data, :y_orientation, prefix),
              hidden: not("y_orientation" in @enabled_annotation_fields),
            ], "control")
        %>

        <%= Layout.number_input(form, :size, [
          id: ID.form_field(form.data, :size, prefix),
          hidden: not("size" in @enabled_annotation_fields)
        ], "control") %>

        <%= Layout.text_input(form, :color, [
          id: ID.form_field(form.data, :color, prefix),
          hidden: not("color" in @enabled_annotation_fields)
        ], "control") %>

        <%= Layout.number_input(form, :thickness, [
          id: ID.form_field(form.data, :thickness, prefix),
          hidden: not("thickness" in @enabled_annotation_fields)
        ], "control") %>

        <%= Layout.number_input(form, :x_offset, [
          id: ID.form_field(form.data, :x_offset, prefix),
          hidden: not("x_offset" in @enabled_annotation_fields)
        ], "control") %>

        <%= Layout.number_input(form, :y_offset, [
          id: ID.form_field(form.data, :y_offset, prefix),
          hidden: not("y_offset" in @enabled_annotation_fields)
        ], "control") %>

        <%= Layout.text_input(form, [
          field_name: :font_size,
          id: ID.form_field(form.data, :font_size),
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
                id: ID.form_field(form.data, :content_id, prefix),
                label: false
              ]) %>

          </div>
        </div>
      </div>

      <%= if form.data.content_id do %>
        <%= inputs_for form, :content, fn fc -> %>
          <section class="card">
            <div class="card-content">
              <div class="content">
                <%= ContentLive.FormComponent.render_fields(assigns, fc,
                  prefix <> ID.prefix(form.data)) %>
              </div>
            </div>
          </section>
        <% end %>
        <div class="level"></div>
      <%= else %>
        no form
      <% end %>
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
end

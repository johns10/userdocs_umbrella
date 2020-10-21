defmodule UserDocsWeb.AnnotationLive.EmbeddedFormComponent do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""


    <div class="field">
      <%= if(@form.data.annotation) do %>
        <div class="card">
          <header class="card-header">
            <p class="card-header-title">
              <%= @form.data.annotation.name %>
            </p>
            <a
              class="card-header-icon"
              phx-click="expand"
              phx-target="<%= @myself.cid %>"
              aria-label="more options">
              <span class="icon" >
                <i class="fa fa-angle-down" aria-hidden="true"></i>
              </span>
            </a>
          </header>
          <%= if(@expanded) do %>
            <div class="card-content">
              <div class="content">
                <%= inputs_for @form, :annotation, fn fp -> %>

                  <div class="field is-grouped">

                    <div class="control">
                      <div class="field">
                        <%= label fp, form_field = :annotation_type_id, class: :label %>
                        <div class="control">
                          <div class="select">
                            <%= select fp, form_field, @annotation_types_select_options,
                              value: @form.data.annotation.annotation_type_id,
                              id: @base_form_id
                              <> "-annotation-"
                              <> Integer.to_string(@form.data.annotation.id)
                              <> "-" <> Atom.to_string(form_field),
                              disabled: @read_only %>
                          </div>
                        </div>
                        <%= error_tag fp, form_field %>
                      </div>
                    </div>

                    <div class="control is-expanded">
                      <div class="field">
                        <%= label fp, form_field = :name, class: "label" %>
                        <div class="control">
                          <%= text_input fp, form_field, class: "input", type: "text", readonly: @read_only,
                            value: @auto_gen_name,
                            id: @base_form_id
                            <> "-annotation-"
                            <> Integer.to_string(@form.data.annotation.id)
                            <> "-" <> Atom.to_string(form_field) %>
                        </div>
                        <%= error_tag fp, form_field %>
                      </div>
                    </div>

                  </div>

                  <div class="field">
                    <%= label fp, form_field = :description, class: "label" %>
                    <div class="control">
                      <%= text_input fp, form_field, class: "input", type: "text", readonly: @read_only,
                        id: @base_form_id
                        <> "-annotation-"
                        <> Integer.to_string(@form.data.annotation.id)
                        <> "-" <> Atom.to_string(form_field) %>
                    </div>
                    <%= error_tag fp, form_field %>
                  </div>

                  <div class="field is-grouped is-grouped-multiline">

                    <%= if("label" in @enabled_fields) do %>
                      <div class="control">
                        <div class="field">
                          <%= label fp, form_field = :label %>
                          <div class="control">
                            <%= text_input fp, form_field, class: "input", type: "text", readonly: @read_only,
                              id: @base_form_id
                              <> "-annotation-"
                              <> Integer.to_string(@form.data.annotation.id)
                              <> "-" <> Atom.to_string(form_field) %>
                          </div>
                          <%= error_tag fp, form_field %>
                        </div>
                      </div>
                    <% end %>

                    <%= if("x_orientation" in @enabled_fields) do %>
                      <div class="control">
                        <div class="field">
                          <%= label fp, :x_orientation, class: :label %>
                          <div class="control">
                            <div class="select">
                              <%= select fp, :x_orientation, [{ "Right", "R" }, {"Middle", "M"}, { "Left", "L" }],
                                readonly: @read_only %>
                            </div>
                          </div>
                          <%= error_tag fp, :x_orientation %>
                        </div>
                      </div>
                    <% end %>

                    <%= if("y_orientation" in @enabled_fields) do %>
                      <div class="control">
                        <div class="field">
                          <%= label fp, :y_orientation, class: :label %>
                          <div class="control">
                            <div class="select">
                              <%= select fp, :y_orientation, [{ "Top", "T" }, {"Middle", "M"}, { "Bottom", "B" }],
                                readonly: @read_only %>
                            </div>
                          </div>
                          <%= error_tag fp, :y_orientation %>
                        </div>
                      </div>
                    <% end %>

                    <%= if("size" in @enabled_fields) do %>
                      <div class="control">
                        <div class="field">
                          <%= label fp, form_field = :size %>
                          <div class="control">
                            <%= number_input fp, form_field, class: "input", type: "text", readonly: @read_only,
                              id: @base_form_id
                              <> "-annotation-"
                              <> Integer.to_string(@form.data.annotation.id)
                              <> "-" <> Atom.to_string(form_field) %>
                          </div>
                          <%= error_tag fp, form_field %>
                        </div>
                      </div>
                    <% end %>

                    <%= if("color" in @enabled_fields) do %>
                      <div class="control">
                        <div class="field">
                          <%= label fp, form_field = :color %>
                          <div class="control">
                            <%= text_input fp, form_field, class: "input", type: "text", readonly: @read_only,
                              id: @base_form_id
                              <> "-annotation-"
                              <> Integer.to_string(@form.data.annotation.id)
                              <> "-" <> Atom.to_string(form_field) %>
                          </div>
                          <%= error_tag fp, form_field %>
                        </div>
                      </div>
                    <% end %>

                    <%= if("thickness" in @enabled_fields) do %>
                      <div class="control">
                        <div class="field">
                          <%= label fp, form_field = :thickness %>
                          <div class="control">
                            <%= number_input fp, form_field, class: "input", type: "text", readonly: @read_only,
                              id: @base_form_id
                              <> "-annotation-"
                              <> Integer.to_string(@form.data.annotation.id)
                              <> "-" <> Atom.to_string(form_field) %>
                          </div>
                          <%= error_tag fp, form_field %>
                        </div>
                      </div>
                    <% end %>

                    <%= if("x_offset" in @enabled_fields) do %>
                      <div class="control">
                        <div class="field">
                          <%= label fp, form_field = :x_offset %>
                          <div class="control">
                            <%= number_input fp, form_field, class: "input", type: "text", readonly: @read_only,
                              id: @base_form_id
                              <> "-annotation-"
                              <> Integer.to_string(@form.data.annotation.id)
                              <> "-" <> Atom.to_string(form_field) %>
                          </div>
                          <%= error_tag fp, form_field %>
                        </div>
                      </div>
                    <% end %>

                    <%= if("y_offset" in @enabled_fields) do %>
                      <div class="control">
                        <div class="field">
                          <%= label fp, form_field = :y_offset %>
                          <div class="control">
                            <%= number_input fp, form_field, class: "input", type: "text", readonly: @read_only,
                              id: @base_form_id
                              <> "-annotation-"
                              <> Integer.to_string(@form.data.annotation.id)
                              <> "-" <> Atom.to_string(form_field) %>
                          </div>
                          <%= error_tag fp, form_field %>
                        </div>
                      </div>
                    <% end %>

                    <%= if("font_size" in @enabled_fields) do %>
                      <div class="control">
                        <div class="field">
                          <%= label fp, form_field = :font_size %>
                          <div class="control">
                            <%= number_input fp, form_field, class: "input", type: "text", readonly: @read_only,
                              id: @base_form_id
                              <> "-annotation-"
                              <> Integer.to_string(@form.data.annotation.id)
                              <> "-" <> Atom.to_string(form_field) %>
                          </div>
                          <%= error_tag fp, form_field %>
                        </div>
                      </div>
                    <% end %>

                  </div>
                  <div class="field is-horizontal">
                    <div class="field-body">
                      <fieldset>
                        <%= label fp, :content_id, class: :label %>
                        <div class="field has-addons">
                          <div class="control">
                            <button class="button" type="button" phx-click="new-content" >
                              <span class="icon" >
                                <i class="fa fa-plus" aria-hidden="true"></i>
                              </span>
                            </button>
                          </div>
                          <div class="control">
                            <div class="select">
                              <%= select fp, :content_id, @contents_select_options,
                                #selected: @changeset.data.content_id,
                                readonly: @read_only,
                                id: @base_form_id
                                <> "-annotation-"
                                <> Integer.to_string(@form.data.annotation.id)
                                <> "-" <> Atom.to_string(form_field) %>
                            </div>
                          </div>
                        </div>
                        <%= error_tag fp, :content_id %>
                      </fieldset>
                      <div class="field">
                        <%= label fp, :version_id, class: :label %>
                        <div class="control">
                          <div class="select">
                            <%= select fp, :version_id, @versions_select_options,
                              selected: @current_version.id,
                              readonly: @read_only,
                              id: @base_form_id
                              <> "-annotation-"
                              <> Integer.to_string(@form.data.annotation.id)
                              <> "-" <> Atom.to_string(form_field) %>
                          </div>
                        </div>
                        <%= error_tag fp, :version_id %>
                      </div>
                    </div>
                  </div>
                  <%= inputs_for fp, :content, fn fc -> %>
                    <%= inputs_for fc, :content_versions, fn fcv -> %>
                      <%= hidden_input fcv, :content_id %>
                      <%= hidden_input fcv, :version_id %>
                      <%= hidden_input fcv, :temp_id %>
                      <div class="field is-horizontal">
                        <div class="control">
                          <div class="select">
                            <%= select fcv, :language_code_id, @language_codes_select_options,
                              value: fcv.data.language_code_id %>
                          </div>
                        </div>
                        <%= error_tag fcv, :language_code_id %>
                      </div>
                      <div class="field">
                        <div class="control">
                          <%= textarea fcv, :body,
                            class: "textarea" %>
                        </div>
                        <%= error_tag fcv, :body %>
                      </div>
                      <div class="field">
                        <div class="control">
                          <%=
                            temp_id = Map.get(fcv.source.changes, :temp_id, fcv.data.temp_id)
                            if is_nil(temp_id) do %>
                            <a
                              class="button"
                              phx-click="delete-content-version"
                              phx-value-id= <%= fcv.data.id %>
                              phx-target="<%= @parent_cid %>"
                            >
                              &times Delete Existing
                            </a>
                          <% else %>
                            <a
                              class="button"
                              phx-click="remove-content-version"
                              phx-value-remove="<%= temp_id %>"
                              phx-target="<%= @parent_cid %>"
                            >
                              &times Delete
                            </a>
                          <% end %>
                        </div>
                      </div>
                    <% end %>
                  <% end %>
                  <%= if(is_integer(fp.data.content_id)) do %>
                    <a
                      class="button"
                      href="#"
                      phx-click="add-content-version"
                      phx-target="<%= @parent_cid %>"
                    >
                      Add a content translation
                    </a>
                  <% end %>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:expanded, false)
      |> assign(:auto_gen_name, "")
    }
  end
  @impl true
  def handle_event("expand", _, socket) do
    socket = assign(socket, :expanded, not socket.assigns.expanded)
    {:noreply, socket}
  end

  defp selector_field_id(page_id, element_id) do
    "page-"
    <> Integer.to_string(page_id)
    <> "-element-"
    <> Integer.to_string(element_id)
    <> "-form-selector-field"
  end
end

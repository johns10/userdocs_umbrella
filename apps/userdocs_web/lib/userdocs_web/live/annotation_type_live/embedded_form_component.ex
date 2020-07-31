defmodule UserDocsWeb.AnnotationLive.EmbeddedFormComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.DomainHelpers

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
                  <div class="field">
                    <%= label fp, form_field = :annotation_type_id, class: :label %>
                    <div class="control">
                      <div class="select">
                        <%= select fp, form_field,
                          DomainHelpers.maybe_select_list(assigns, :available_annotation_types),
                          value: @form.data.annotation.annotation_type_id,
                          id: @base_form_id
                          <> "-annotation-"
                          <> Integer.to_string(@form.data.annotation.id)
                          <> "-" <> Atom.to_string(form_field) %>
                      </div>
                    </div>
                    <%= error_tag fp, form_field %>
                  </div>
                  <div class="field">
                    <%= label fp, form_field = :name, class: "label" %>
                    <div class="control">
                      <%= text_input fp, form_field, class: "input", type: "text", readonly: @read_only,
                        id: @base_form_id
                        <> "-annotation-"
                        <> Integer.to_string(@form.data.annotation.id)
                        <> "-" <> Atom.to_string(form_field) %>
                    </div>
                    <%= error_tag fp, form_field %>
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
                  <%= if("label" in @enabled_fields) do %>
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
                  <% end %>
                  <%= if("x_orientation" in @enabled_fields) do %>
                    <div class="field">
                      <%= label fp, form_field = :x_orientation %>
                      <div class="control">
                        <%= text_input fp, form_field, class: "input", type: "text", readonly: @read_only,
                          id: @base_form_id
                          <> "-annotation-"
                          <> Integer.to_string(@form.data.annotation.id)
                          <> "-" <> Atom.to_string(form_field) %>
                      </div>
                      <%= error_tag fp, form_field %>
                    </div>
                  <% end %>
                  <%= if("y_orientation" in @enabled_fields) do %>
                    <div class="field">
                      <%= label fp, form_field = :y_orientation %>
                      <div class="control">
                        <%= text_input fp, form_field, class: "input", type: "text", readonly: @read_only,
                          id: @base_form_id
                          <> "-annotation-"
                          <> Integer.to_string(@form.data.annotation.id)
                          <> "-" <> Atom.to_string(form_field) %>
                      </div>
                      <%= error_tag fp, form_field %>
                    </div>
                  <% end %>
                  <%= if("size" in @enabled_fields) do %>
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
                  <% end %>
                  <%= if("color" in @enabled_fields) do %>
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
                  <% end %>
                  <%= if("thickness" in @enabled_fields) do %>
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
                  <% end %>
                  <%= if("x_offset" in @enabled_fields) do %>
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
                  <% end %>
                  <%= if("y_offset" in @enabled_fields) do %>
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
                  <% end %>
                  <%= if("font_size" in @enabled_fields) do %>
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
    socket =
      socket
      |> assign(:expanded, false)

      {:ok, socket}
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

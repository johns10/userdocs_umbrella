defmodule UserDocsWeb.ElementLive.EmbeddedFormComponent do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div class="field">
      <%= if(@form.data.element != nil) do %>
        <div class="card">
          <header class="card-header">
            <p class="card-header-title">
              <%= @form.data.element.name %>
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
                <%= inputs_for @form, :element, fn fp -> %>
                  <div class="field">
                    <%= label fp, :name, class: "label" %>
                    <div class="control">
                      <%= text_input fp, :name, class: "input", type: "text", readonly: @read_only,
                        id: @base_form_id
                          <> "-element-"
                          <> Integer.to_string(@form.data.element.id)
                          <> "-name" %>
                    </div>
                    <%= error_tag fp, :name %>
                  </div>

                  <div class="field">
                    <%= label fp, :strategy, class: "label" %>
                    <div class="control">
                      <%= text_input fp, :strategy, class: "input", type: "text", readonly: @read_only,
                      id: @base_form_id <> "-element-" <> Integer.to_string(@form.data.element.id) <> "-strategy" %>
                    </div>
                    <%= error_tag fp, :strategy %>
                  </div>

                  <div class="field">
                    <%= label fp, :selector, class: "label" %>
                    <p class="control">
                      <div class="field has-addons">
                        <p class="control">
                          <%= text_input fp, :selector, class: "input", type: "text", readonly: @read_only,
                          id: @base_form_id <> "-element-" <> Integer.to_string(@form.data.element.id) <> "-selector" %>
                        </p>
                        <p class="control">
                          <button class="button"
                            target="<%= selector_field_id(@form.data.id, fp.data.id) %>"
                            phx-hook="CopySelector">
                            <span class="icon" >
                              <i class="fa fa-arrow-left"
                                aria-hidden="true"
                                target="<%= selector_field_id(@form.data.id, fp.data.id) %>"></i>
                            </span>
                          </span>
                        </p>
                        <!-- TODO validate that @changeset.data.selector works here -->
                        <p class="control">
                          <button class="button"
                            selector="<%= fp.data.selector %>"
                            phx-hook="testSelector">
                            <span class="icon" >
                              <i class="fa fa-cloud-upload"
                                aria-hidden="true"
                                selector="<%= fp.data.selector %>"></i>
                            </span>
                          </span>
                        </p>
                      </div>
                      <%= error_tag fp, :selector %>
                    </p>
                  </div>
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

  defp selector_field_id(page_id, nil), do: selector_field_id(page_id, 0)
  defp selector_field_id(page_id, element_id) when is_integer(page_id) and is_integer(element_id) do
    "page-"
    <> Integer.to_string(page_id)
    <> "-element-"
    <> Integer.to_string(element_id)
    <> "-form-selector-field"
  end

end

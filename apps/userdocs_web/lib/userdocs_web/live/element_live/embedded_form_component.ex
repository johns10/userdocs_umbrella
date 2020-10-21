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
                    <%= label fp, :selector, class: "label" %>
                    <p class="control">
                      <div class="field has-addons">
                        <div class="control">
                          <%= select fp, :strategy_id, @strategies_select_options,
                            class: "input",
                            type: "text",
                            readonly: @read_only,
                            id: strategy_field_id(fp.data.page_id, fp.data.id) %>
                        </div>
                        <p class="control is-expanded">
                          <%= text_input fp, :selector, class: "input", type: "text", readonly: @read_only,
                          id: selector_field_id(fp.data.page_id, fp.data.id) %>
                        </p>
                        <div class="control">
                          <button
                            class="button"
                            type="button"
                            selector="<%= selector_field_id(fp.data.page_id, fp.data.id) %>"
                            strategy="<%= strategy_field_id(fp.data.page_id, fp.data.id) %>"
                            phx-hook="CopySelector"
                          >
                            <span class="icon" >
                              <i
                                class="fa fa-arrow-left"
                                aria-hidden="true"
                              ></i>
                            </span>
                          </span>
                        </div>
                        <!-- TODO validate that @changeset.data.selector works here -->
                          <p class="control">
                          <button
                            type="button"
                            class="button"
                            phx-target="<%= @myself.cid %>"
                            phx-value-element-id="<%= fp.data.id %>"
                            phx-value-selector="<%= selector_field_id(fp.data.page_id, fp.data.id) %>"
                            phx-value-strategy="<%= strategy_field_id(fp.data.page_id, fp.data.id) %>"
                            phx-click="test_selector"
                          >
                            <span class="icon" >
                              <i class="fa fa-cloud-upload"
                                aria-hidden="true"
                              ></i>
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

  def handle_event("test_selector", %{ "element-id" => element_id }, socket) do
    element_id = String.to_integer(element_id)

    IO.puts("Testing selector")

    element =
      socket.assigns.elements
      |> Enum.filter(fn(e) -> e.id == element_id end)
      |> Enum.at(0)

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

  defp strategy_field_id(page_id, nil), do: strategy_field_id(page_id, 0)
  defp strategy_field_id(page_id, element_id) when is_integer(page_id) and is_integer(element_id) do
    "page-"
    <> Integer.to_string(page_id)
    <> "-element-"
    <> Integer.to_string(element_id)
    <> "-form-strategy-field"
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

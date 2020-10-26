defmodule ProcessAdministratorWeb.EmbeddedFormComponent do
  use ProcessAdministratorWeb, :live_component
  use Phoenix.HTML

  alias ProcessAdministratorWeb.VersionLive
  alias ProcessAdministratorWeb.LiveHelpers
  alias ProcessAdministratorWeb.ID

  alias UserDocs.Web
  alias UserDocs.Automation

  @impl true
  def render(assigns) do
    ~L"""
      <div id="<%= @id %>">
        <%= f = form_for @parent_changeset, "#",
          phx_change: @event_name,
          phx_target: @myself.cid %>
          <%= hidden_input f, :id, value: f.data.id %>
          <div class="control is-expanded">
            <div class="select">
              <%= select f, @key, @select_options, value: @selected %>
            </div>
          </div>
        </form>
        <div class="level"></div>
        <div class="card" id="<%= @id %>">
          <header class="card-header">
            <p class="card-header-title"  style="margin-bottom:0px;">
              <%= @object.name || "No Name" %>
            </p>
            <a
              class="card-header-icon"
              phx-click="expand"
              phx-target="<%= @myself.cid %>"
              aria-label="expand">
              <span class="icon" >
                <i class="fa fa-angle-down" aria-hidden="true"></i>
              </span>
            </a>
          </header>
          <div class="card-content <%= is_expanded?(@expanded) %>">
            <div class="content">
              <%=
                LiveHelpers.live_form(@socket, @object_form, [
                  action: :edit,
                  id: ID.form(@parent, :edit, @object_type),
                  parent: @parent,
                  type: @object_type,
                  data: @data,
                  object: @object,
                  select_lists: @select_lists
                ])
              %>
            </div>
          </div>
        </div>
      </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:expanded, false)
      |> assign(:show_form, false)
      |> assign(:footer_action, :none)
    }
  end

  @impl true
  def handle_event("expand", _, socket) do
    {
      :noreply,
      assign(socket, :expanded, not socket.assigns.expanded)
    }
  end

  def is_expanded?(false), do: " is-hidden"
  def is_expanded?(true), do: ""
end

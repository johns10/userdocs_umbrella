defmodule ProcessAdministratorWeb.CollapsableFormComponent do
  use ProcessAdministratorWeb, :live_component
  use Phoenix.HTML

  alias ProcessAdministratorWeb.VersionLive
  alias ProcessAdministratorWeb.LiveHelpers
  alias ProcessAdministratorWeb.ID

  @impl true
  def render(assigns) do
    ~L"""
      <div class="card" id="<%= @id %>">
        <header class="card-header">
          <p class="card-header-title" style="margin-bottom:0px;">
            <%= @title  %>
          </p>
          <%= @runner %>
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
                object: @object,
                id: ID.form(@object, :edit, @object_type),
                parent: @parent,
                type: @object_type,
                data: @data,
                select_lists: @select_lists
              ])
            %>
            <div class="level"></div>
          </div>
        </div>
      </div>
    """
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
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  @impl true
  def handle_event("expand", _, socket) do
    IO.inspect("Expanding collapsible formzs")
    socket = assign(socket, :expanded, not socket.assigns.expanded)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    {
      :noreply,
      socket
      |> assign(:footer_action, :new)
    }
  end

  @impl true
  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, :footer_action, :show)}
  end

  def show_form?(:new), do: ""
  def show_form?(_), do: " is-hidden"

  def is_expanded?(false), do: " is-hidden"
  def is_expanded?(true), do: ""
end

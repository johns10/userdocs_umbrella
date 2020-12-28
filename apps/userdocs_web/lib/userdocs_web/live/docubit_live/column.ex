defmodule UserDocsWeb.DocubitLive.Renderers.Column do
  use UserDocsWeb, :live_component
  use Phoenix.HTML
  alias UserDocsWeb.DocubitLive.AddDocubitButton

  @impl true
  def mount(socket) do
    allowed_children =
      UserDocs.Documents.DocubitType.column_attrs()
      |> Map.get(:allowed_children)

    {
      :ok,
      socket
      |> assign(:display_create_menu, false)
      |> assign(:allowed_children, allowed_children)
    }
  end

  def render(assigns) do
    ~L"""
      <div class="">
        <%= @inner_content.([]) %>
        <div class="dropdown is-active">
          <%= new_docubit_button(assigns) %>
          <%= if @display_create_menu do %>
            <%= new_docubit_dropdown(assigns) %>
          <% end %>
        </div>
      </div>
    """
  end

  def new_docubit_button(assigns) do
    ~L"""
    <div class="dropdown-trigger">
      <a class="button"
        aria-haspopup="true"
        aria-controls="dropdown-menu"
        phx-click="display-create-menu"
        phx-value-docubit-type=""
        phx-target="<%= @myself.cid %>"
        phx-value-id=<%= @docubit.id %>
      >+</a>
    </div>
    """
  end

  def new_docubit_dropdown(assigns) do
    ~L"""
      <div class="dropdown-menu" id="dropdown-menu" role="menu">
        <div class="dropdown-content">
          <%= for allowed_child <- @allowed_children do %>
            <%= AddDocubitButton.render(%{
              text: allowed_child,
              class: "dropdown-item",
              parent_cid: @parent_cid,
              docubit: @docubit,
              type: allowed_child}) %>
          <% end %>
        </div>
      </div>
    """
  end

  @impl true
  def handle_event("display-create-menu", _, socket) do
    { :noreply, assign(socket, :display_create_menu, not socket.assigns.display_create_menu) }
  end
end

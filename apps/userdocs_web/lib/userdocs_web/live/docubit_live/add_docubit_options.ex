defmodule UserDocsWeb.DocubitLive.AddDocubitOptions do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
      <%= if @editor do %>
        <div class="field">
          <div class="control">
            <div class="buttons">
              <%= if @display_create_menu do %>
                <%= new_docubit_options(assigns) %>
              <% else %>
                <%= add_docubit_button(assigns) %>
              <% end %>
            </div>
          </div>
        </div>
      <% end %>
    """
  end

  def add_docubit_button(assigns) do
    ~L"""
      <a class="button"
        aria-haspopup="true"
        phx-click="display-create-menu"
        phx-target="<%= @myself.cid %>"
      >+</a>
    """
  end

  def new_docubit_options(assigns) do
    ~L"""
      <a class="button"
        phx-click="display-create-menu"
        phx-target="<%= @myself.cid %>"
      >-</a>
      <%= for allowed_child <- @docubit.docubit_type.allowed_children do %>
        <a class="button"
          phx-click="create-docubit"
          phx-value-type=<%= allowed_child %>
          phx-target="<%= @parent_cid %>"
          phx-value-docubit-id=<%= @docubit.id %>
        ><%= allowed_child %></a>
      <% end %>
    """
  end

  def display_create_menu(socket) do
    assign(socket, :display_create_menu, not socket.assigns.display_create_menu)
  end
end

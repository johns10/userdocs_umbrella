defmodule UserDocsWeb.UserLive.LoginFormComponent do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns, path) do
    ~L"""
      <%= form_for @changeset, path, [as: :user], fn f -> %>
        <%= if @changeset.action do %>
          <div class="alert alert-danger">
            <p>Oops, something went wrong! Please check the errors below.</p>
          </div>
        <% end %>

        <%= label f, Pow.Ecto.Schema.user_id_field(@changeset) %>
        <%= text_input f, Pow.Ecto.Schema.user_id_field(@changeset) %>
        <%= error_tag f, Pow.Ecto.Schema.user_id_field(@changeset) %>

        <%= label f, :password %>
        <%= password_input f, :password %>
        <%= error_tag f, :password %>

        <div>
          <%= submit "Sign in" %>
        </div>
      <% end %>
    """
  end
end

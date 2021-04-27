defmodule UserDocsWeb.UserLive.FormComponent do
  use UserDocsWeb, :live_component
  alias UserDocsWeb.Layout

  alias UserDocs.Users

  @impl true
  def render(%{ action: :options } = assigns) do
    ~L"""
      h2 <%= @title %>

      <%= f = form_for @changeset, "#",
        id: "user-form",
        phx_target: @myself.cid,
        phx_change: "validate",
        phx_submit: "save" %>

        <%= Layout.text_input f, :email, [], "control" %>
        <%= Layout.text_input f, :image_path, [], "control" %>

        <%= inputs_for f, :team_users, fn tuf -> %>
          <div class="field is-grouped">
            <%= hidden_input tuf, :user_id, value: f.data.id %>
            <%= Layout.checkbox tuf, :default %>
            <%= Layout.select_input tuf, :team_id, @select_lists.teams, [], "control px-2" %>
            <%= if is_nil tuf.data.temp_id do %>
              <%= Layout.checkbox tuf, :delete %>
            <% else %>
              <%= hidden_input tuf, :temp_id %>
              <%= link(to: "#", phx_click: "remove-team", phx_value_remove: tuf.data.temp_id, phx_target: @myself.cid) do %>
                <span>x</span>
              <% end %>
            <% end %>
          </div>
        <% end %>
        <%= error_tag f, :team_users %>
        <%= submit "Save", phx_disable_with: "Saving..." %>
      </form>
    """
  end
  def render(%{ action: action } = assigns) when action in [ :new, :edit ] do
    ~L"""
      <h2 class="title"><%= @title %>
      <%= form_for @changeset, Routes.pow_registration_path(@socket, :update), [
        phx_target: @myself.cid, phx_change: "validate", phx_submit: "save", id: "user-form", as: :user
      ], fn f -> %>
        <%= Layout.text_input(f, Pow.Ecto.Schema.user_id_field(@changeset), [], "control") %>

        <div class="field">
          <%= label f, :current_password, class: "label" %>
          <div>
            <%= password_input f, :current_password, class: :input, type: :password %>
          </div>
          <%= error_tag f, :current_password %>
        </div>

        <div class="field">
          <%= label f, :password, class: "label" %>
          <div>
            <%= password_input f, :password, class: :input, type: :password %>
          </div>
          <%= error_tag f, :password %>
        </div>

        <div class="field">
          <%= label f, :password_confirmation, class: "label" %>
          <div>
            <%= password_input f, :password_confirmation, class: :input, type: :password %>
          </div>
          <%= error_tag f, :password_confirmation %>
        </div>

        <div>
          <%= submit "Update", class: "button is-primary" %>
        </div>

      <% end %>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Users.change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, %{ assigns: %{ action: :options } } = socket) do
    changeset =
      socket.assigns.user
      |> Users.change_user_options(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Users.update_user(socket.assigns.user, user_params) do
      {:ok, _user} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "User updated successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_user(socket, :new, user_params) do
    case Users.create_user(user_params) do
      {:ok, user} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "User created successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_user(socket, :options, user_params) do
    case Users.update_user_options(socket.assigns.user, user_params) do
      {:ok, user} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "User updated successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

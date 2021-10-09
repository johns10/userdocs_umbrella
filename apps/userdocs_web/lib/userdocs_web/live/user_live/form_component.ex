defmodule UserDocsWeb.UserLive.FormComponent do
  use UserDocsWeb, :live_component
  alias UserDocsWeb.Layout

  alias UserDocs.Users
  alias UserDocs.Users.Override

  @impl true
  def render(%{action: :options} = assigns) do
    ~L"""
      <h2 class="title"><%= @title %></h2>

      <%= f = form_for @changeset, "#",
        id: "user-form",
        phx_target: @myself.cid,
        phx_change: "validate",
        phx_submit: "save" %>

        <div class="form-control">
          <%= label f, :email, class: "label" %>
          <%= text_input f, :email, type: "text", class: "input input-sm input-bordered" %>
          <%= error_tag f, :email %>
        </div>

        <div class="flex justify-between items-center">
          <%= label f, :overrides, class: "label" %>
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
          </svg>
        </div>
        <%= inputs_for f, :overrides, [append: @append_overrides], fn puof -> %>
          <div class="flex items-center mb-2">
            <div class="flex-1 mr-4">
              <%= select puof, :project_id, @project_select_options, class: "select select-sm select-bordered" %>
              <%= error_tag(puof, :project_id) %>
            </div>
            <div class="flex-auto mr-2">
              <%= text_input puof, :url, class: "input input-sm input-bordered" %>
              <%= error_tag(puof, :url) %>
            </div>
            <%= hidden_input puof, :temp_id %>
            <%= if is_nil(Ecto.Changeset.get_field(puof.source, :temp_id)) do %>
              <%= checkbox puof, :delete, class: "checkbox" %>
            <% else %>
              <%= link(to: "#", phx_click: "remove-override", phx_value_temp_id: puof.data.temp_id, phx_target: @myself.cid) do %>
              <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
              <% end %>
            <% end %>
          </div>
        <% end %>

        <%= link to: "#", class: "btn btn-sm btn-success", phx_click: "add-override", phx_target: @myself.cid, id: "add-override" do %>
          <p>New Override</p>
        <% end %>

        <div class="grid grid-cols-6 gap-4">
          <label class="label">Default</label>
          <label class="label col-span-4">Team</label>
          <label class="label">Delete</label>
          <%= inputs_for f, :team_users, fn tuf -> %>
            <%= hidden_input tuf, :user_id, value: f.data.id %>
            <%= checkbox tuf, :default, class: "checkbox mr-4" %>
            <%= select tuf, :team_id, @select_lists.teams, class: "select select-sm select-bordered col-span-4" %>
            <%= if is_nil tuf.data.temp_id do %>
              <%= checkbox tuf, :delete, class: "checkbox" %>
            <% else %>
              <%= hidden_input tuf, :temp_id %>
              <%= link(to: "#", phx_click: "remove-team", phx_value_remove: tuf.data.temp_id, phx_target: @myself.cid) do %>
                <span>x</span>
              <% end %>
            <% end %>
          <% end %>
        </div>
        <%= error_tag f, :team_users %>

        <div class="mt-4">
          <%= submit "Save", phx_disable_with: "Saving...", class: "btn btn-primary mr-2" %>
        </div>
      </form>
    """
  end
  def render(%{action: action} = assigns) when action in [ :new, :edit ] do
    ~L"""
      <h2 class="title"><%= @title %></h2>
      <%= form_for @changeset, registration_path(@socket, action, @user), [
        phx_target: @myself.cid, phx_change: "validate", phx_submit: "save", id: "user-form", as: :user
      ], fn f -> %>
        <div class="form-control">
          <%= label f, Pow.Ecto.Schema.user_id_field(@changeset), class: "label" %>
          <%= text_input f, Pow.Ecto.Schema.user_id_field(@changeset), type: "text", class: "input input-bordered" %>
          <%= error_tag f, Pow.Ecto.Schema.user_id_field(@changeset) %>
        </div>

        <div class="form-control">
          <%= label f, :current_password, class: "label" %>
          <%= password_input f, :current_password, class: "input input-bordered" %>
          <%= error_tag f, :current_password %>
        </div>

        <div class="form-control">
          <%= label f, :password, class: "label" %>
          <%= password_input f, :password, class: "input input-bordered" %>
          <%= error_tag f, :password %>
        </div>

        <div class="form-control">
          <%= label f, :password_confirmation, class: "label" %>
          <%= password_input f, :password_confirmation, class: "input input-bordered" %>
          <%= error_tag f, :password_confirmation %>
        </div>

        <div class="mt-4">
          <%= submit "Save", phx_disable_with: "Saving...", class: "btn btn-primary mr-2" %>
        </div>

      <% end %>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Users.change_user(user)
    project_select_options =
      UserDocs.Projects.list_projects(%{}, %{user_id: user.id})
      |> UserDocs.Helpers.select_list(:name, true)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:project_select_options, project_select_options)
      |> assign(:append_overrides, [])
    }
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, %{assigns: %{action: :options}} = socket) do
    changeset =
      socket.assigns.user
      |> Users.change_user_options(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end
  @impl true
  def handle_event("validate", %{"user" => _user_params}, socket) do
    # blank validation, for tests
    {:noreply, socket}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  def handle_event("add-override", _, socket) do
    append_overrides =
      socket.assigns.append_overrides
      |> Enum.concat([Users.change_override(%Override{temp_id: UUID.uuid4()})])

    {:noreply, assign(socket, append_overrides: append_overrides)}
  end

  def handle_event("remove-override", %{"temp-id" => temp_id}, socket) do
    append_overrides =
      socket.assigns.append_overrides
      |> Enum.reject(fn %{data: override} -> override.temp_id  == temp_id end)

    {
      :noreply,
      socket
      |> assign(append_overrides: append_overrides)
    }
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
      {:ok, _user} ->
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
    #user_params = Map.put(user_params, "overrides", [])
    case Users.update_user_options(socket.assigns.user, user_params) do
      {:ok, user} ->
        overrides =
          user.overrides
          |> Enum.map(fn(o) -> Map.take(o, [:url, :project_id]) end)

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

  def registration_path(socket, :new, _user), do: Routes.registration_path(socket, :new)
  def registration_path(socket, :edit, user), do: Routes.registration_path(socket, :edit, user)
end

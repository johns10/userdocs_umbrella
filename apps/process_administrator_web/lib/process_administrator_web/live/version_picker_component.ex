defmodule ProcessAdministratorWeb.VersionPicker do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  alias ProcessAdministratorWeb.State

  alias UserDocs.Projects.Select
  alias ProcessAdministratorWeb.Layout

  @impl true
  def render(assigns) do
    ~L"""
      <div class="field is-grouped" id="<%= @id %>">
        <p class="control">
          <%= f = form_for :team, "#",
            id: "select-team-form",
            phx_change: "select_team" %>

              <%= Layout.select_input(f, :id, @teams_select_options,
                value: @current_team_id, label: false) %>

          </form>
        </p>
        <p class="control">
          <div class="field has-addons">

            <%= Layout.new_item_button("new-project", [ ], "control") %>

            <%= f = form_for :project, "#",
              id: "select-project-form",
              phx_change: "select_project" %>

              <%= Layout.select_input(f, :id, @projects_select_options,
                value: @current_project_id, label: false) %>

            </form>

            <%= if @current_project != nil do %>

              <%= Layout.edit_item_button("edit-project", [ ], "control") %>

            <% end %>

          </div>
        </p>
        <p class="control">
          <div class="field has-addons">

            <%= Layout.new_item_button("new-version", [ ], "control") %>

            <%= f = form_for :version, "#",
              id: "select-version-form",
              phx_change: "select_version" %>

              <%= Layout.select_input(f, :id, @versions_select_options,
                value: @current_version_id, label: false) %>

            </form>

            <%= if @current_version != nil do %>

              <%= Layout.edit_item_button("edit-version", [ ], "control") %>

            <% end %>

          </div>
        </p>
      </div>
    """
  end

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
    }
  end

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> State.apply_changes(Select.initialize_select_options(assigns))
    }
  end

  @impl true
  def handle_event("select_team", %{ "team" => %{"id" => id} }, socket) do
    changes = Select.handle_team_selection(socket.assigns, String.to_integer(id))
    {:noreply, State.apply_changes(socket, changes)}
  end

  @impl true
  def handle_event("select_project", %{ "project" => %{"id" => id} }, socket) do
    changes = Select.handle_project_selection(socket.assigns, String.to_integer(id))
    {:noreply, State.apply_changes(socket, changes)}
  end

  @impl true
  def handle_event("select_version", %{ "version" => %{"id" => id} }, socket) do
    changes = Select.handle_version_selection(socket.assigns, String.to_integer(id))
    send(socket.root_pid, {:update_current_version, changes})
    {:noreply, State.apply_changes(socket, changes)}
  end
end

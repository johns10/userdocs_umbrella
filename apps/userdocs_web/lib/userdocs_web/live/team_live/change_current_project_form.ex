defmodule UserDocsWeb.TeamLive.CurrentProject do
  use UserDocsWeb, :live_view

  alias UserDocs.Users.User

  @spec render(any, %User{}, list(), binary()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns, changeset, projects, change_event) do
    ~L"""
    <%= f = form_for changeset, "#",
      id: "user-form",
      phx_change: change_event,
      phx_submit: "save" %>
      <div class="control">
        <div class="select is-primary">
          <%= select f, :default_project_id, projects %>
        </div>
      </div>
    </form>
    """
  end
end

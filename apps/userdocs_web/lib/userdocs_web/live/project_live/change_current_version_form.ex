defmodule UserDocsWeb.ProjectLive.CurrentVersion do
  use UserDocsWeb, :live_view

  alias UserDocs.Users.User

  @spec render(any, %User{}, list(), binary()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns, changeset, versions, change_event) do
    ~L"""
    <%= f = form_for changeset, "#",
      id: "project-form",
      phx_change: change_event,
      phx_submit: "save" %>
      <div class="control">
        <div class="select is-primary">
          <%= select f, :default_version_id, versions %>
        </div>
      </div>
    </form>
    """
  end
end

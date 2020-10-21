defmodule UserDocsWeb.UserLive.ChangeCurrentTeam do
  use UserDocsWeb, :live_view

  alias UserDocs.Users.User

  @spec render(any, %User{}, list(), binary()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns, changeset, teams, change_event) do
    ~L"""
    <%= f = form_for changeset, "#",
      id: "user-form",
      phx_change: change_event,
      phx_submit: "save" %>



      <div class="field">
        <div class="control">
          <div class="select is-primary">
            <%= select f, :default_team_id, teams %>
          </div>
        </div>
      </div>
    </form>
    """
  end
end

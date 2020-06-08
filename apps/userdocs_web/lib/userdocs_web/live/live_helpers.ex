defmodule UserDocsWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `UserDocsWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, UserDocsWeb.TeamUserLive.FormComponent,
        id: @team_user.id || :new,
        action: @live_action,
        team_user: @team_user,
        return_to: Routes.team_user_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, UserDocsWeb.ModalComponent, modal_opts)
  end
end

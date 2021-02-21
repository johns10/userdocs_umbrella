defmodule UserDocsWeb.UserLive.Show do
  use UserDocsWeb, :live_view

  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Users

  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Root

  @impl true
  def mount(_params, session, socket) do
    opts = Defaults.base_opts()
    {
      :ok,
      socket
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:user, Users.get_user!(id))
    }
  end

  defp page_title(:show), do: "Show User"
  defp page_title(:edit), do: "Edit User"
end

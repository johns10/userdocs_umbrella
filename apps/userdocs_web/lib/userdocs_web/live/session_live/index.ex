defmodule UserDocsWeb.SessionLive.Index do
  @moduledoc """
  Index for signups
  """
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper
  alias UserDocs.Users.User

  @impl true
  def mount(_params, _session, socket) do
    user = %User{}
    {
      :ok,
      socket
      |> assign(:auth_state, :not_logged_in)
      |> assign(:page_title, "Sign In")
      |> assign(:live_action, :create)
      |> assign(:user, user)
    }
  end
end

defmodule UserDocsWeb.SignupLive.Index do
  @moduledoc """
  Index for signups
  """
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper
  alias UserDocs.Users.User
  alias UserDocs.Users
  require Logger

  @impl true
  def mount(_params, %{"os" => os}, socket) do
    {
      :ok,
      socket
      |> assign(:auth_state, :not_logged_in)
      |> assign(:os, os)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Sign Up for UserDocs")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Set Up UserDocs")
    |> assign(:user, Users.get_user!(id))
  end
end

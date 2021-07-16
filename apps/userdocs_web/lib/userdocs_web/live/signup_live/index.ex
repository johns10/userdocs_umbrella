defmodule UserDocsWeb.SignupLive.Index do
  use UserDocsWeb, :live_view

  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Users.User

  require Logger

  @impl true
  def mount(_params, %{ "os" => os}, socket) do
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

  defp apply_action(socket, :setup, _params) do
    socket
    |> assign(:page_title, "Set Up UserDocs")
    |> assign(:user, %User{})
  end
end

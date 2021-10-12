defmodule UserDocsWeb.RegistrationLive.Index do
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
  def handle_params(params, url, socket) do
    {
      :noreply,
      socket
      |> apply_action(socket.assigns.live_action, params)
      |> assign(url: URI.parse(url))
    }
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Sign Up for UserDocs")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Set Up UserDocs")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Set Up UserDocs")
    |> assign(:user, Users.get_user!(id))
  end
end

defmodule UserDocsWeb.UserLive.Index do
  use UserDocsWeb, :live_view

  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Users
  alias UserDocs.Users.User
  alias UserDocsWeb.Root

  def types() do
    [
      UserDocs.Users.User,
      UserDocs.Users.TeamUser,
      UserDocs.Users.Team
    ]
  end

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> Root.apply(session, types())
      |> initialize()
    }
  end

  def initialize(%{assigns: %{current_user: %{email: "johns10davenport@gmail.com"}}} = socket) do
    socket
    |> assign(:users, list_users())
  end
  def initialize(socket) do
    if Mix.env() in [:dev, :test] do
      assign(socket, :users, list_users())
    else
      socket
    end
  end

  @impl true
  def handle_params(params, url, socket) do
    {:noreply, socket |> apply_action(socket.assigns.live_action, params) |> assign(url: URI.parse(url))}
  end

  defp apply_action(socket, :local_options, _) do
    socket
    |> assign(:page_title, "Edit Local Options")
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Users.get_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Users.get_user!(id)
    {:ok, _} = Users.delete_user(user)

    {:noreply, assign(socket, :users, list_users())}
  end
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  defp list_users do
    Users.list_users()
  end

  @impl true
  def handle_info(n, s), do: Root.handle_info(n, s)
end

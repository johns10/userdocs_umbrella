defmodule UserDocsWeb.VersionLive.Show do
  use UserDocsWeb, :live_view

  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Projects
  alias UserDocs.Users
  alias UserDocs.Projects.Version
  alias UserDocs.Helpers

  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Root
  alias UserDocsWeb.ComposableBreadCrumb

  @types [
    UserDocs.Projects.Version
  ]

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> Root.authorize(session)
      |> Root.initialize(Defaults.base_opts(@types))
      |> initialize()
    }
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    opts = Defaults.state_opts(socket)

    socket
    |> assign(:modal_action, :show)
    |> assign(:state_opts, opts)
  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(%{ "id" => id }, _, socket) do
    version = Projects.get_version!(String.to_integer(id), %{ processes: true, strategy: true })
    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:version, version)
    }
  end

  @impl true
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  @impl true
  def handle_info(n, s), do: Root.handle_info(n, s)

  defp page_title(:show), do: "Show Project"
  defp page_title(:edit), do: "Edit Project"

end

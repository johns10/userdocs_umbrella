defmodule UserDocsWeb.RegistrationLive.SetupComponent do
  @moduledoc """
    Component that's displayed after signing up, used for setup instructions
  """
  use UserDocsWeb, :live_component

  alias UserDocs.Users

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:windows_agents, ["Windows", "Windows CE", "Windows IoT", "Windows Mobile"])
      |> assign(:macintosh_agents, ["Mac"])
      |> assign(:linux_agents, ["Ubuntu", "Arch Linux", "Debian", "Fedora", "FreeBSD", "Knoppix", "GNU/Linux", "Lubuntu", "Mint", "OpenBSD", "Red Hat", "SUSE"])
      |> assign(:windows_path, "https://github.com/user-docs/userdocs_clients/releases/latest/download/UserDocs-Setup.exe")
      |> assign(:macintosh_path, "https://github.com/user-docs/userdocs_clients/releases/latest/download/UserDocs-Setup.dmg")
      |> assign(:linux_path, "https://github.com/user-docs/userdocs_clients/releases/latest/download/UserDocs-Setup.AppImage")
    }
  end

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

end

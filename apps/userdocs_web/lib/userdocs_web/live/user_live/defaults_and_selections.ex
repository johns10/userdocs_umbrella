defmodule UserDocsWeb.UserLive.DefaultsAndSelections do
  use UserDocsWeb, :live_component

  def render(assigns) do
    ~L"""
      <p> Selected Team: <%= @selected_team_name %> </p>
      <p> Selected Project: <%= @selected_project_name %> </p>
      <p> Selected Version: <%= @selected_version_name %> </p>
      <p> Default Team: <%= @default_team_name %> </p>
      <p> Default Project: <%= @default_project_name %> </p>
      <p> Default Version: <%= @default_version_name %> </p>
    """
  end

  def update(%{ current_user: current_user }, socket) do
    default_team = Map.get(current_user, :default_team, %UserDocs.Users.Team{ name: "Not Found" }) || %UserDocs.Users.Team{ name: "Not Found" }
    default_project =
      case Map.get(default_team, :default_project, %UserDocs.Projects.Project{ name: "Not Found" }) do
        nil -> %UserDocs.Projects.Project{ name: "Not Found" }
        r -> r
      end
    default_version = Map.get(default_project, :default_version, %UserDocs.Projects.Version{ name: "Not Found" })
    {
      :ok,
      socket
      |> assign(:selected_team_name, Map.get(current_user.selected_team, :name, "None found"))
      |> assign(:selected_project_name, Map.get(current_user.selected_project, :name, "None found"))
      |> assign(:selected_version_name, Map.get(current_user.selected_version, :name, "None found"))
      |> assign(:default_team_name, Map.get(default_team, :name, "None found"))
      |> assign(:default_project_name, Map.get(default_project, :name, "None found"))
      |> assign(:default_version_name, Map.get(default_version, :name, "None found"))
    }
  end
end

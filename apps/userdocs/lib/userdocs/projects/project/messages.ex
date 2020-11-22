defmodule UserDocs.Project.Messages do

  alias UserDocs.Projects.Project
  alias UserDocs.Helpers

  def new_modal_menu(socket) do
    %{ target: "ModalMenus" }
    |> init(socket)
    |> new(socket)
  end

  def edit_modal_menu(socket) do
    %{ target: "ModalMenus" }
    |> init(socket)
    |> edit(socket)
  end

  defp edit(message, socket) do
    message
    |> Map.put(:object, socket.assigns.current_project)
    |> Map.put(:action, :edit)
    |> Map.put(:title, "Edit Project")
  end

  defp new(message, _socket) do
    message
    |> Map.put(:object, %Project{})
    |> Map.put(:action, :new)
    |> Map.put(:title, "New Project")
  end

  defp init(message, socket) do
    select_lists = %{
      teams:
        Helpers.select_list(socket.assigns.teams, :name, false)
    }

    message
    |> Map.put(:type, :project)
    |> Map.put(:parent, socket.assigns.current_team)
    |> Map.put(:select_lists, select_lists)
  end
end

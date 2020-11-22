defmodule UserDocs.Version.Messages do

  alias UserDocs.Projects.Version
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
    |> Map.put(:object, socket.assigns.current_version)
    |> Map.put(:action, :edit)
    |> Map.put(:title, "Edit Version")
  end

  defp new(message, _socket) do
    message
    |> Map.put(:object, %Version{})
    |> Map.put(:action, :new)
    |> Map.put(:title, "New Version")
  end

  defp init(message, socket) do
    select_lists = %{
      projects:
        socket.assigns.projects
        |> Enum.filter(fn(p) -> p.team_id == socket.assigns.current_team.id end)
        |> Helpers.select_list(:name, false),

      strategies:
        Helpers.select_list(socket.assigns.strategies, :name, false)
    }

    message
    |> Map.put(:type, :version)
    |> Map.put(:parent, socket.assigns.current_project)
    |> Map.put(:select_lists, select_lists)
  end
end

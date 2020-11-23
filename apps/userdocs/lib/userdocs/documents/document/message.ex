defmodule UserDocs.Document.Messages do

  alias UserDocs.Users
  alias UserDocs.Documents.Document
  alias UserDocs.Helpers

  def new_modal_menu(socket, parent, projects, channel) do
    %{ target: "ModalMenus" }
    |> init(socket, parent, projects, channel)
    |> new(socket)
  end

  defp new(message, _socket) do
    message
    |> Map.put(:object, %Document{})
    |> Map.put(:action, :new)
    |> Map.put(:title, "New Document")
  end

  defp init(message, _socket, parent, projects, channel) do
    select_lists = %{
      projects:
        projects
        |> Helpers.select_list(:name, false),
    }

    message
    |> Map.put(:type, :document)
    |> Map.put(:parent, parent)
    |> Map.put(:select_lists, select_lists)
    |> Map.put(:channel, channel)
  end
end

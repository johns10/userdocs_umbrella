defmodule UserDocs.Process.Messages do

  alias UserDocs.Automation.Process
  alias UserDocs.Helpers

  def new_modal_menu(socket, params) do
    required_keys = [ :project_id, :versions, :version_id ]
    params = Helpers.validate_params(params, required_keys, __MODULE__)

    %{ target: "ModalMenus" }
    |> init(socket, params.project_id, params.versions, params.version_id)
    |> new(socket)
  end

  defp new(message, _socket) do
    message
    |> Map.put(:object, %Process{})
    |> Map.put(:action, :new)
    |> Map.put(:title, "New Process")
  end

  defp init(message, _socket, project_id, versions, version_id) do
    select_lists = %{
      versions:
        versions
        |> Helpers.select_list(:name, false),
    }

    message
    |> Map.put(:type, :process)
    |> Map.put(:project_id, project_id)
    |> Map.put(:version_id, version_id)
    |> Map.put(:select_lists, select_lists)
  end
end

defmodule UserDocs.DocumentVersion.Messages do

  alias UserDocs.Documents.DocumentVersion
  alias UserDocs.Helpers

  def new_modal_menu(socket, params) do
    required_keys = [ :document_id, :version_id, :documents, :versions, :channel]
    params =
      case Enum.all?(required_keys, &Map.has_key?(params, &1)) do
        true -> params
        false -> raise("DocumentVersion.Messages.new_modal_menu doesn't have all required keys.  Missing #{inspect(required_keys -- Map.keys(params))}")
      end

    %{ target: "ModalMenus" }
    |> init(socket, params.document_id, params.version_id, params.documents, params.versions, params.channel)
    |> new(socket)
  end

  defp new(message, _socket) do
    message
    |> Map.put(:object, %DocumentVersion{})
    |> Map.put(:action, :new)
    |> Map.put(:title, "New Document Version")
  end

  defp init(message, _socket, document_id, version_id, documents, versions, channel) do
    select_lists = %{
      documents: Helpers.select_list(documents, :name, false),
      versions: Helpers.select_list(versions, :name, false)
    }

    message
    |> Map.put(:type, :document_version)
    |> Map.put(:document_id, document_id)
    |> Map.put(:version_id, version_id)
    |> Map.put(:select_lists, select_lists)
    |> Map.put(:channel, channel)
  end
end

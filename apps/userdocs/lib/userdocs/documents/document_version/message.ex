defmodule UserDocs.DocumentVersion.Messages do

  alias UserDocs.Documents
  alias UserDocs.Projects
  alias UserDocs.Documents.DocumentVersion
  alias UserDocs.Helpers

  def new_modal_menu(socket, params) do
    required_keys = [ :document_id, :version_id, :documents, :versions, :channel, :state_opts]
    params = Helpers.validate_params(params, required_keys, __MODULE__)

    %{ target: "ModalMenus" }
    |> init(socket, params.document_id, params.version_id, params.documents, params.versions, params.channel)
    |> new(socket, params.document_id, params.version_id, params.state_opts)
  end

  def edit_modal_menu(socket, params) do
    required_keys = [ :document_id, :document_version_id, :version_id, :documents, :versions, :document_versions, :channel]
    params = Helpers.validate_params(params, required_keys, __MODULE__)
    %{ target: "ModalMenus" }
    |> init(socket, params.document_id, params.version_id, params.documents, params.versions, params.channel)
    |> edit(socket, params.document_version_id, params.opts)
  end

  defp edit(message, socket, document_version_id, opts) do
    message
    |> Map.put(:object, Documents.get_document_version!(document_version_id, socket, opts))
    |> Map.put(:action, :edit)
    |> Map.put(:title, "Edit Document Version")
  end

  defp new(message, socket, document_id, version_id, state_opts) do
    document = Documents.get_document!(document_id, socket, state_opts)
    version = Projects.get_version!(version_id, socket, state_opts)
    name = document.title <>" (" <> version.name <> ")"

    message
    |> Map.put(:object, %DocumentVersion{ name: name })
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

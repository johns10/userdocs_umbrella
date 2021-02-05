defmodule UserDocs.Document.Messages do

  alias UserDocs.Documents
  alias UserDocs.Documents.Document
  alias UserDocs.Helpers

  def new_modal_menu(socket, params) do
    required_keys = [ :team, :projects, :channel, :state_opts]
    params = Helpers.validate_params(params, required_keys, __MODULE__)

    %{ target: "ModalMenus" }
    |> init(socket, params.team, params.projects, params.channel)
    |> new(socket)
  end

  def edit_modal_menu(socket, params) do
    required_keys = [ :team, :projects, :channel, :document_id, :state_opts]
    params = Helpers.validate_params(params, required_keys, __MODULE__)

    %{ target: "ModalMenus" }
    |> init(socket, params.team, params.projects, params.channel)
    |> edit(socket, params.document_id, params.state_opts)
  end

  defp new(message, _socket) do
    message
    |> Map.put(:object, %Document{})
    |> Map.put(:action, :new)
    |> Map.put(:title, "New Document")
  end

  defp edit(message, socket, document_id, state_opts) do
    message
    |> Map.put(:object, Documents.get_document!(document_id, socket, state_opts))
    |> Map.put(:action, :edit)
    |> Map.put(:title, "Edit Document")
  end

  defp init(message, _socket, team, projects, channel) do
    select_lists = %{
      projects:
        projects
        |> Helpers.select_list(:name, false),
    }

    message
    |> Map.put(:type, :document)
    |> Map.put(:team_id, team.id)
    |> Map.put(:select_lists, select_lists)
    |> Map.put(:channel, channel)
  end
end

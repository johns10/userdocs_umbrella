defmodule UserDocs.Documents.Content.Messages do

  alias UserDocs.Documents
  alias UserDocs.Documents.Content
  alias UserDocs.Helpers

  def new_modal_menu(socket, params) do
    required_keys = [ :version_id, :team, :teams, :language_codes, :versions, :content, :channel, :state_opts ]
    params = Helpers.validate_params(params, required_keys, __MODULE__)

    %{ target: "ModalMenus" }
    |> init(socket, params.team, params.teams, params.channel,
        params.version_id, params.language_codes, params.versions,
        params.content, params.state_opts)
    |> new(socket)
  end

  def edit_modal_menu(socket, params) do
    required_keys = [ :version_id, :team, :teams, :language_codes, :versions, :content, :channel, :state_opts ]
    params = Helpers.validate_params(params, required_keys, __MODULE__)

    %{ target: "ModalMenus" }
    |> init(socket, params.team, params.teams, params.channel,
        params.version_id, params.language_codes, params.versions,
        params.content, params.state_opts)
    |> edit(socket, params.content_id, params.state_opts)
  end

  defp new(message, _socket) do
    message
    |> Map.put(:object, %Content{})
    |> Map.put(:action, :new)
    |> Map.put(:title, "New Document")
  end

  defp edit(message, socket, content_id, state_opts) do
    state_opts =
      state_opts
      |> Keyword.put(:preloads, [ :content_versions ])

    message
    |> Map.put(:object, Documents.get_content!(content_id, socket, state_opts))
    |> Map.put(:action, :edit)
    |> Map.put(:title, "Edit Document")
  end

  defp init(message, _socket, team, teams, channel, version_id, language_codes, versions, content, state_opts) do
    select_lists = %{
      teams: Helpers.select_list(teams, :name, false),
      language_codes: Helpers.select_list(language_codes, :name, false),
      versions: Helpers.select_list(versions, :name, false),
      content: Helpers.select_list(content, :name, false)
    }

    message
    |> Map.put(:type, :content)
    |> Map.put(:team_id, team.id)
    |> Map.put(:select_lists, select_lists)
    |> Map.put(:channel, channel)
    |> Map.put(:version_id, version_id)
    |> Map.put(:state_opts, state_opts)
  end
end

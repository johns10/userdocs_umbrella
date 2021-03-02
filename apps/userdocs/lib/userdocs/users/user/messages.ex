defmodule UserDocs.Users.User.Messages do

  alias UserDocs.Users
  alias UserDocs.Helpers

  def edit_modal_menu(socket, params) do
    required_keys = [ :user_id, :state_opts, :teams ]
    params = Helpers.validate_params(params, required_keys, __MODULE__)

    %{ target: "ModalMenus" }
    |> init(socket, params.teams)
    |> edit(socket, params.user_id, params.state_opts)
  end

  defp edit(message, socket, user_id, state_opts) do
    message
    |> Map.put(:object, Users.get_user!(user_id, socket, state_opts))
    |> Map.put(:action, :edit)
    |> Map.put(:title, "Edit User")
  end

  defp init(message, _socket, teams) do
    select_lists = %{
      teams:
        teams
        |> Helpers.select_list(:name, false),
    }

    message
    |> Map.put(:type, :user)
    |> Map.put(:select_lists, select_lists)
  end
end

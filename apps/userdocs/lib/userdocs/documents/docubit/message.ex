defmodule UserDocs.Docubit.Messages do
  alias UserDocs.Helpers

  def edit_modal_menu(socket, params) do
    required_keys = [ :docubit, :channel, :state_opts ]
    params = Helpers.validate_params(params, required_keys, __MODULE__)

    %{ target: "ModalMenus" }
    |> init(socket, params.channel)
    |> edit(socket, params.docubit, params.state_opts)
  end

  defp edit(message, _socket, docubit, _opts) do
    message
    |> Map.put(:object, docubit)
    |> Map.put(:action, :edit)
    |> Map.put(:title, "Edit Docubit")
  end

  defp init(message, _socket, channel) do
    message
    |> Map.put(:type, :docubit)
    |> Map.put(:channel, channel)
  end
end

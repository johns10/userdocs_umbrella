defmodule UserDocs.Docubit.Messages do

  alias UserDocs.Documents
  alias UserDocs.Helpers

  def edit_modal_menu(socket, params) do
    required_keys = [ :docubit, :channel, :opts ]
    params = Helpers.validate_params(params, required_keys, __MODULE__)

    %{ target: "ModalMenus" }
    |> init(socket, params.channel)
    |> edit(socket, params.docubit, params.opts)
  end

  defp edit(message, socket, docubit, opts) do
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

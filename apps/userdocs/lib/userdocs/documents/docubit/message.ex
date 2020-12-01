defmodule UserDocs.Docubit.Messages do

  alias UserDocs.Documents.Docubit
  alias UserDocs.Helpers

  def new_modal_menu(socket, params) do
    required_keys = [ :docubit_id, :document_version_id, :channel, :opts, :allowed_children ]
    params = Helpers.validate_params(params, required_keys, __MODULE__)

    %{ target: "ModalMenus" }
    |> init(socket, params.document_version_id, params.allowed_children, params.channel)
    |> new(socket)
  end

  defp new(message, _socket) do
    message
    |> Map.put(:object, %Docubit{})
    |> Map.put(:action, :new)
    |> Map.put(:title, "New Docubit")
  end

  defp init(message, _socket, document_version_id, allowed_children, channel) do
    select_lists = %{
      allowed_children:
      allowed_children
        |> Helpers.select_list(:name, false),
    }

    message
    |> Map.put(:type, :docubit)
    |> Map.put(:document_version_id, document_version_id)
    |> Map.put(:channel, channel)
    |> Map.put(:select_lists, select_lists)
  end
end

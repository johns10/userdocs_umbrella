defmodule UserDocs.Documents.Body do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Documents.Docubit, as: Docubit

  schema "docubits" do
    embeds_one :container, Docubit
  end

  def changeset(body, attrs) do
    body
    |> cast_embed(attrs, [ :container ])
    |> container_docubit_if_empty()
  end

  defp container_docubit_if_empty(changeset) do
    container = Kernel.struct(Docubit, %{ type_id: "container", })
    case get_change(changeset, :container) do
      nil -> put_change(changeset, :container, container)
      "" -> put_change(changeset, :container, container)
        _ -> changeset
    end
  end
end

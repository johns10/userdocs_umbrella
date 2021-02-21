defmodule UserDocs.Documents.Docubit.Address do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Documents.Docubit

  @derive {Jason.Encoder, only: [:docubit_id, :body]}

  @primary_key false
  schema "address" do
    belongs_to :docubit, Docubit
    field :body, { :map, EctoAddress }
  end


  @doc false
  def changeset(document_version, attrs) do
    document_version
    |> cast(attrs, [ :body, :docubit_id ])
    |> foreign_key_constraint(:docubit)
  end
end

defmodule UserDocs.Documents.LanguageCode do

  # mix phx.gen.live Documents LanguageCode language_codes code:string

  use Ecto.Schema
  import Ecto.Changeset

  schema "language_codes" do
    field :code, :string

    timestamps()
  end

  @doc false
  def changeset(language_code, attrs) do
    language_code
    |> cast(attrs, [:code])
    |> validate_required([:code])
  end
end

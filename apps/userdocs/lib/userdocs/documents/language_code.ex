defmodule UserDocs.Documents.LanguageCode do

  # mix phx.gen.live Documents LanguageCode language_codes code:string

  use Ecto.Schema
  import Ecto.Changeset

  schema "language_codes" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(language_code, attrs) do
    language_code
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

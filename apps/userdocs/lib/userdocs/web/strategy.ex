defmodule UserDocs.Web.Strategy do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name]}
  schema "strategies" do
    field :name, :string
  end

  @doc false
  def changeset(element, attrs) do
    element
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def safe(strategy, _handlers \\ %{})
  def safe(strategy = %UserDocs.Web.Strategy{}, _handlers) do
    base_safe(strategy)
  end
  def safe(nil, _), do: nil

  def base_safe(strategy = %UserDocs.Web.Strategy{}) do
    %{
      id: strategy.id,
      name: strategy.name
    }
  end
end

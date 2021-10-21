defmodule UserDocs.Elements.Element do
  use Ecto.Schema
  import Ecto.Changeset
  alias UserDocs.Pages.Page
  alias UserDocs.Web.Strategy

  @derive {Jason.Encoder, only: [:id, :name, :selector]}
  schema "elements" do
    field :name, :string
    field :selector, :string

    belongs_to :strategy, Strategy
    belongs_to :page, Page

    timestamps()
  end

  @doc false
  def changeset(element, attrs) do
    element
    |> cast(attrs, [:name, :strategy_id, :selector, :page_id])
    |> foreign_key_constraint(:strategy_id)
    |> foreign_key_constraint(:page_id)
    |> validate_required([:strategy_id, :selector, :page_id])
    |> ignore_missing()
  end

  def fields_changeset(element, attrs) do
    element
    |> cast(attrs, [:name, :strategy_id, :selector, :page_id])
    |> validate_required([:strategy_id, :selector, :page_id])
    |> ignore_missing()
  end

  def ignore_missing(changeset) do
    case changeset do
      %{valid?: false, changes: changes} = changeset when changes == %{ } ->
        %{changeset | action: :ignore}
      changeset ->
        changeset
    end
  end

  def safe(element, handlers \\ %{})
  def safe(element = %UserDocs.Elements.Element{}, handlers) do
    base_safe(element)
    |> maybe_safe_strategy(handlers[:strategy], element.strategy, handlers)
    |> maybe_safe_page(handlers[:page], element.page, handlers)
  end
  def safe(nil, _), do: nil

  def base_safe(element) do
    %{
      id: element.id,
      name: element.name,
      selector: element.selector
    }
  end

  def maybe_safe_strategy(element, nil, _, _), do: element
  def maybe_safe_strategy(element, handler, strategy, handlers) do
    Map.put(element, :strategy, handler.(strategy, handlers))
  end

  def maybe_safe_page(element, nil, _, _), do: element
  def maybe_safe_page(element, handler, page, handlers) do
    Map.put(element, :page, handler.(page, handlers))
  end
end

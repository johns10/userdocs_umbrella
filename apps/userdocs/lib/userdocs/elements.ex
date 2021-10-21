defmodule UserDocs.Elements do
  @moduledoc """
  The Elements context.
  """
  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.Elements.Element

  def load_elements(state, opts) do
    StateHandlers.load(state, list_elements(opts[:params], opts[:filters]), Element, opts)
  end

  def list_elements(params \\ %{}, filters \\ %{})
  def list_elements(params, filters) when is_map(params) and is_map(filters) do
    base_elements_query()
    |> maybe_filter_element_by_page(filters[:page_id])
    |> maybe_filter_element_by_project(filters[:project_id])
    |> maybe_preload_strategy(params[:strategy])
    |> Repo.all()
  end
  def list_elements(state, opts) when is_list(opts) do
    StateHandlers.list(state, Element, opts)
    |> maybe_preload_element(opts[:preloads], state, opts)
  end

  defp maybe_preload_element(element, nil, _, _), do: element
  defp maybe_preload_element(element, _preloads, state, opts) do
    opts = Keyword.delete(opts, :filter)
    StateHandlers.preload(state, element, opts)
  end

  defp base_elements_query(), do: from(elements in Element)

  defp maybe_filter_element_by_page(query, nil), do: query
  defp maybe_filter_element_by_page(query, page_id) do
    from(element in query,
      where: element.page_id == ^page_id
    )
  end

  defp maybe_filter_element_by_project(query, nil), do: query
  defp maybe_filter_element_by_project(query, project_id) do
    from(element in query,
      left_join: page in assoc(element, :page),
      where: page.project_id == ^project_id
    )
  end

  defp maybe_preload_strategy(query, nil), do: query
  defp maybe_preload_strategy(query, _), do: from(elements in query, preload: [:strategy])

  def get_element!(id, _params \\ %{}, _filters \\ %{})
  def get_element!(id, params, filters) when is_map(params) and is_map(filters) do
    base_element_query(id)
    |> maybe_preload_strategy(params[:strategy])
    |> Repo.one!()
  end
  def get_element!(id, state, opts) when is_list(opts) do
    StateHandlers.get(state, id, Element, opts)
    |> maybe_preload_element(opts[:preloads], state, opts)
  end

  defp base_element_query(id) do
    from(element in Element, where: element.id == ^id)
  end

  def create_element(attrs \\ %{}) do
    %Element{}
    |> Element.changeset(attrs)
    |> Repo.insert()
  end

  def update_element(%Element{} = element, attrs) do
    element
    |> Element.changeset(attrs)
    |> Repo.update()
  end

  def delete_element(%Element{} = element) do
    Repo.delete(element)
  end

  def change_element(%Element{} = element, attrs \\ %{}) do
    Element.changeset(element, attrs)
  end
end

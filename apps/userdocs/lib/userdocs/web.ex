defmodule UserDocs.Web do
  @moduledoc """
  The Web context.
  """

  import Ecto.Query, warn: false

  alias UserDocs.Repo
  alias UserDocs.Subscription
  alias UserDocs.Web.Page

  def load_pages(state, opts) do
    StateHandlers.load(state, list_pages(%{}, opts[:filters]), Page, opts)
  end


  @doc """
  Returns the list of pages.

  ## Examples

      iex> list_pages()
      [%Page{}, ...]

  """
  def list_pages(params \\ %{}, filters \\ %{})
  def list_pages(state, opts) when is_list(opts) do
    StateHandlers.list(state, Page, opts)
  end
  def list_pages(params, filters) when is_map(params) and is_map(filters) do
    base_pages_query()
    |> maybe_preload_elements(params[:elements])
    |> maybe_preload_annotations(params[:annotations])
    |> maybe_filter_pages_by_team_id(filters[:team_id])
    |> maybe_filter_pages_by_project_id(filters[:project_id])
    |> Repo.all()
  end

  defp maybe_preload_elements(query, nil), do: query
  defp maybe_preload_elements(query, _), do: from(pages in query, preload: [:elements])

  defp maybe_preload_annotations(query, nil), do: query
  defp maybe_preload_annotations(query, _), do: from(pages in query, preload: [:annotations])

  defp maybe_filter_pages_by_team_id(query, nil), do: query
  defp maybe_filter_pages_by_team_id(query, team_id) do
    from(page in query,
      left_join: project in UserDocs.Projects.Project, on: page.project_id == project.id,
      left_join: team in UserDocs.Users.Team, on: project.team_id == team.id,
      where: team.id == ^team_id)
  end

  defp maybe_filter_pages_by_project_id(query, nil), do: query
  defp maybe_filter_pages_by_project_id(query, project_id) do
    from(page in query, where: page.project_id == ^project_id)
  end

  defp base_pages_query(), do: from(pages in Page)

  @doc """
  Gets a single page.

  Raises `Ecto.NoResultsError` if the Page does not exist.

  ## Examples

      iex> get_page!(123)
      %Page{}

      iex> get_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_page!(id), do: Repo.get!(Page, id)
  def get_page!(id, state, opts) when is_list(opts) do
    StateHandlers.get(state, id, Page, opts)
  end

  @doc """
  Creates a page.

  ## Examples

      iex> create_page(%{field: value})
      {:ok, %Page{}}

      iex> create_page(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_page(attrs \\ %{}) do
    %Page{}
    |> Page.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a page.

  ## Examples

      iex> update_page(page, %{field: new_value})
      {:ok, %Page{}}

      iex> update_page(page, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_page(%Page{} = page, attrs) do
    page
    |> Page.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a page.

  ## Examples

      iex> delete_page(page)
      {:ok, %Page{}}

      iex> delete_page(page)
      {:error, %Ecto.Changeset{}}

  """
  def delete_page(%Page{} = page) do
    Repo.delete(page)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking page changes.

  ## Examples

      iex> change_page(page)
      %Ecto.Changeset{data: %Page{}}

  """
  def change_page(%Page{} = page, attrs \\ %{}) do
    Page.changeset(page, attrs)
  end

  alias UserDocs.Elements.Element

  def load_elements(state, opts) do
    StateHandlers.load(state, list_elements(opts[:params], opts[:filters]), Element, opts)
  end
  @doc """
  Returns the list of elements.

  ## Examples

      iex> list_elements()
      [%Element{}, ...]

  """
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

  defp maybe_preload_strategy(query, nil), do: query
  defp maybe_preload_strategy(query, _), do: from(elements in query, preload: [:strategy])

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

  defp base_elements_query(), do: from(elements in Element)

  @doc """
  Gets a single element.

  Raises `Ecto.NoResultsError` if the Element does not exist.

  ## Examples

      iex> get_element!(123)
      %Element{}

      iex> get_element!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element!(id, _params \\ %{}, _filters \\ %{})
  def get_element!(id, params, filters) when is_map(params) and is_map(filters) do
    base_element_query(id)
    |> maybe_preload_strategy(params[:strategy])
    |> Repo.one!()
  end
  def get_element!(id, state, opts) when is_list(opts) do
    StateHandlers.get(state, id, Element, opts)
  end

  defp base_element_query(id) do
    from(element in Element, where: element.id == ^id)
  end

  @doc """
  Creates a element.

  ## Examples

      iex> create_element(%{field: value})
      {:ok, %Element{}}

      iex> create_element(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_element(attrs \\ %{}) do
    %Element{}
    |> Element.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a element.

  ## Examples

      iex> update_element(element, %{field: new_value})
      {:ok, %Element{}}

      iex> update_element(element, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_element(%Element{} = element, attrs) do
    element
    |> Element.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a element.

  ## Examples

      iex> delete_element(element)
      {:ok, %Element{}}

      iex> delete_element(element)
      {:error, %Ecto.Changeset{}}

  """
  def delete_element(%Element{} = element) do
    Repo.delete(element)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking element changes.

  ## Examples

      iex> change_element(element)
      %Ecto.Changeset{data: %Element{}}

  """
  def change_element(%Element{} = element, attrs \\ %{}) do
    Element.changeset(element, attrs)
  end

  alias UserDocs.Web.Strategy

  def load_strategies(state, opts) do
    StateHandlers.load(state, list_strategies(), Strategy, opts)
  end

  @doc """
  Returns the list of strategies.
  """
  def list_strategies(state, opts) when is_list(opts) do
    StateHandlers.list(state, Strategy, opts)
  end
  def list_strategies do
    Repo.all(Strategy)
  end

  def css_strategy do
    list_strategies()
    |> Enum.filter(fn(s) -> s.name == "css" end)
    |> Enum.at(0)
  end

  def get_strategy!(id, state, opts) do
    StateHandlers.get(state, id, Strategy, opts)
  end

  def create_strategy(attrs \\ %{}) do
    %Strategy{}
    |> Strategy.changeset(attrs)
    |> Repo.insert()
  end
end

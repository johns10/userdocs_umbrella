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
    |> maybe_filter_by_version(filters[:version_id])
    |> maybe_filter_pages_by_team_id(filters[:team_id])
    |> Repo.all()
  end

  defp maybe_preload_elements(query, nil), do: query
  defp maybe_preload_elements(query, _), do: from(pages in query, preload: [:elements])

  defp maybe_preload_annotations(query, nil), do: query
  defp maybe_preload_annotations(query, _), do: from(pages in query, preload: [:annotations])

  defp maybe_filter_by_version(query, nil), do: query
  defp maybe_filter_by_version(query, version_id) do
    from(page in query,
      where: page.version_id == ^version_id
    )
  end

  defp maybe_filter_pages_by_team_id(query, nil), do: query
  defp maybe_filter_pages_by_team_id(query, team_id) do
    from(page in query,
      left_join: version in UserDocs.Projects.Version, on: version.id == page.version_id,
      left_join: project in UserDocs.Projects.Project, on: version.project_id == project.id,
      left_join: team in UserDocs.Users.Team, on: project.team_id == team.id,
      where: team.id == ^team_id)
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

  alias UserDocs.Web.AnnotationType

  def load_annotation_types(state, opts) do
    StateHandlers.load(state, list_annotation_types(), AnnotationType, opts)
  end

  @doc """
  Returns the list of annotation_types.

  ## Examples

      iex> list_annotation_types()
      [%AnnotationType{}, ...]

  """
  def list_annotation_types(state, opts) when is_list(opts) do
    StateHandlers.list(state, AnnotationType, opts)
  end
  def list_annotation_types do
    Repo.all(AnnotationType)
  end

  @doc """
  Gets a single annotation_type.

  Raises `Ecto.NoResultsError` if the Annotation type does not exist.

  ## Examples

      iex> get_annotation_type!(123)
      %AnnotationType{}

      iex> get_annotation_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_annotation_type!(id, _params \\ %{}, _filters \\ %{})
  def get_annotation_type!(id, _params, _filters) do
    Repo.get!(AnnotationType, id)
  end
  def get_annotation_type!(id, _params, _filters, state) do
    UserDocs.State.get!(state, id, :annotation_types, AnnotationType)
  end

  @doc """
  Creates a annotation_type.

  ## Examples

      iex> create_annotation_type(%{field: value})
      {:ok, %AnnotationType{}}

      iex> create_annotation_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_annotation_type(attrs \\ %{}) do
    %AnnotationType{}
    |> AnnotationType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a annotation_type.

  ## Examples

      iex> update_annotation_type(annotation_type, %{field: new_value})
      {:ok, %AnnotationType{}}

      iex> update_annotation_type(annotation_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_annotation_type(%AnnotationType{} = annotation_type, attrs) do
    annotation_type
    |> AnnotationType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a annotation_type.

  ## Examples

      iex> delete_annotation_type(annotation_type)
      {:ok, %AnnotationType{}}

      iex> delete_annotation_type(annotation_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_annotation_type(%AnnotationType{} = annotation_type) do
    Repo.delete(annotation_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking annotation_type changes.

  ## Examples

      iex> change_annotation_type(annotation_type)
      %Ecto.Changeset{data: %AnnotationType{}}

  """
  def change_annotation_type(%AnnotationType{} = annotation_type, attrs \\ %{}) do
    AnnotationType.changeset(annotation_type, attrs)
  end

  alias UserDocs.Web.Element

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
    |> maybe_filter_by_version_id(filters[:team_id])
    |> maybe_preload_strategy(params[:strategy])
    |> Repo.all()
  end
  def list_elements(state, opts) when is_list(opts) do
    StateHandlers.list(state, Element, opts)
  end

  defp maybe_preload_strategy(query, nil), do: query
  defp maybe_preload_strategy(query, _), do: from(elements in query, preload: [:strategy])

  defp maybe_preload_strategy(object, nil, _), do: object
  defp maybe_preload_strategy(object, _, state) do
    strategy =
      state.strategies
      |> Enum.filter(fn(s) -> s.id == object.strategy_id end)
      |> Enum.at(0)

    object
    |> Map.put(:strategy, strategy)
  end

  defp maybe_filter_by_version_id(query, nil), do: query
  defp maybe_filter_by_version_id(query, team_id) do
    from(element in query,
      left_join: page in UserDocs.Web.Page, on: page.id == element.page_id,
      left_join: version in UserDocs.Projects.Version, on: version.id == page.version_id,
      left_join: project in UserDocs.Projects.Project, on: project.id == version.project_id,
      left_join: team in UserDocs.Users.Team, on: team.id == project.team_id,
      where: team.id == ^team_id)
  end

  defp maybe_filter_element_by_page(query, nil), do: query
  defp maybe_filter_element_by_page(query, page_id) do
    from(element in query,
      where: element.page_id == ^page_id
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
    Repo.get!(Element, id)
  end
  def get_element!(id, state, opts) when is_list(opts) do
    StateHandlers.get(state, id, Element, opts)
  end


  def get_content!(id, params, _filters, state) do
    UserDocs.State.get!(state, id, :content, Content)
    |> maybe_preload_strategy(params[:content_versions], state)
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

  alias UserDocs.Web.Annotation

  def load_annotations(state, opts) do
    StateHandlers.load(state, list_annotations(opts[:params], opts[:filters]), Annotation, opts)
  end

  @doc """
  Returns the list of annotations.

  ## Examples

      iex> list_annotations()
      [%Annotation{}, ...]

  """
  def list_annotations(params \\ %{}, filters \\ %{})
  def list_annotations(state, opts) when is_list(opts) do
    StateHandlers.list(state, Annotation, opts)
    |> maybe_preload_annotation(opts[:preloads], state, opts)
  end
  def list_annotations(params, filters) when is_map(params) and is_map(filters) do
    base_annotation_query()
    |> maybe_filter_annotation_by_page(filters[:page_id])
    |> maybe_filter_annotation_by_version_id(filters[:version_id])
    |> maybe_filter_annotation_by_team_id(filters[:team_id])
    |> maybe_preload_content(params[:content])
    |> maybe_preload_content_versions(params[:content_versions])
    |> maybe_preload_annotation_type(params[:annotation_type])
    |> order_by(:name)
    |> Repo.all()
  end

  defp maybe_preload_annotation(annotation, nil, _, _), do: annotation
  defp maybe_preload_annotation(annotation, _preloads, state, opts) do
    opts = Keyword.delete(opts, :filter)
    StateHandlers.preload(state, annotation, opts)
  end

  defp maybe_preload_annotation_type(query, nil), do: query
  defp maybe_preload_annotation_type(query, _), do: from(annotations in query, preload: [:annotation_type])
  defp maybe_preload_annotation_type(object, nil, _), do: object
  defp maybe_preload_annotation_type(object, _, state) do
    annotation_type =
      state.annotation_types
      |> Enum.filter(fn(at) -> at.id == object.annotation_type_id end)
      |> Enum.at(0)

    object
    |> Map.put(:annotation_type, annotation_type)
  end

  defp maybe_preload_content(query, nil), do: query
  defp maybe_preload_content(query, _), do: from(annotations in query, preload: [:content])

  defp maybe_preload_content_versions(query, nil), do: query
  defp maybe_preload_content_versions(query, _) do
    from(annotation in query,
      left_join: content in UserDocs.Documents.Content, on: annotation.content_id == content.id,
      preload: [
        :content,
        content: :content_versions,
      ])
  end

  defp maybe_filter_annotation_by_version_id(query, nil), do: query
  defp maybe_filter_annotation_by_version_id(query, version_id) do
    from(annotation in query,
      left_join: page in assoc(annotation, :page),
      where: page.version_id == ^version_id)
  end

  defp maybe_filter_annotation_by_team_id(query, nil), do: query
  defp maybe_filter_annotation_by_team_id(query, team_id) do
    from(annotation in query,
      left_join: page in UserDocs.Web.Page, on: page.id == annotation.page_id,
      left_join: version in UserDocs.Projects.Version, on: version.id == page.version_id,
      left_join: project in UserDocs.Projects.Project, on: version.project_id == project.id,
      left_join: team in UserDocs.Users.Team, on: project.team_id == team.id,
      where: team.id == ^team_id)
  end


  defp maybe_filter_annotation_by_page(query, nil), do: query
  defp maybe_filter_annotation_by_page(query, page_id) do
    from(annotation in query,
      where: annotation.page_id == ^page_id
    )
  end

  def base_annotation_query(), do: from(annotations in Annotation)

  @doc """
  Gets a single annotation.

  Raises `Ecto.NoResultsError` if the Annotation does not exist.

  ## Examples

      iex> get_annotation!(123)
      %Annotation{}

      iex> get_annotation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_annotation!(id), do: Repo.get!(Annotation, id)
  def get_annotation!(%{ annotations: annotations }, id), do: get_annotation!(annotations, id)
  def get_annotation!(id, params, _filters, state) do
    UserDocs.State.get!(state, id, :annotations, Annotation)
    |> maybe_preload_annotation_type(params[:annotation_type], state)
  end
  def get_annotation!(id, state, opts) when is_list(opts) do
    StateHandlers.get(state, id, Annotation, opts)
    |> maybe_preload_annotation(opts[:preloads], state, opts)
  end

  @doc """
  Creates a annotation.

  ## Examples

      iex> create_annotation(%{field: value})
      {:ok, %Annotation{}}

      iex> create_annotation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_annotation(attrs \\ %{}) do
    %Annotation{}
    |> Annotation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a annotation.

  ## Examples

      iex> update_annotation(annotation, %{field: new_value})
      {:ok, %Annotation{}}

      iex> update_annotation(annotation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_annotation(%Annotation{} = annotation, attrs) do
    changeset = Annotation.changeset(annotation, attrs)
    {status, annotation} = Repo.update(changeset)
    { status, annotation }
  end

  def update_annotation_content_id(%Annotation{} = annotation, %{ content_id: content_id }) do
    annotation
    |> Annotation.changeset(%{})
    |> Ecto.Changeset.put_change(:content_id, content_id)
    |> Repo.update()
  end

  @doc """
  Deletes a annotation.

  ## Examples

      iex> delete_annotation(annotation)
      {:ok, %Annotation{}}

      iex> delete_annotation(annotation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_annotation(%Annotation{} = annotation) do
    Repo.delete(annotation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking annotation changes.

  ## Examples

      iex> change_annotation(annotation)
      %Ecto.Changeset{data: %Annotation{}}

  """
  def change_annotation(%Annotation{} = annotation, attrs \\ %{}) do
    Annotation.changeset(annotation, attrs)
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

  def get_strategy!(id, state, opts) do
    StateHandlers.get(state, id, Strategy, opts)
  end

  def create_strategy(attrs \\ %{}) do
    %Strategy{}
    |> Strategy.changeset(attrs)
    |> Repo.insert()
  end
end

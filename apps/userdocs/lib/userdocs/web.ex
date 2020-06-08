defmodule UserDocs.Web do
  @moduledoc """
  The Web context.
  """

  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.Web.Page

  @doc """
  Returns the list of pages.

  ## Examples

      iex> list_pages()
      [%Page{}, ...]

  """
  def list_pages do
    Repo.all(Page)
  end

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

  @doc """
  Returns the list of annotation_types.

  ## Examples

      iex> list_annotation_types()
      [%AnnotationType{}, ...]

  """
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
  def get_annotation_type!(id), do: Repo.get!(AnnotationType, id)

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

  @doc """
  Returns the list of elements.

  ## Examples

      iex> list_elements()
      [%Element{}, ...]

  """
  def list_elements do
    Repo.all(Element)
  end

  @doc """
  Gets a single element.

  Raises `Ecto.NoResultsError` if the Element does not exist.

  ## Examples

      iex> get_element!(123)
      %Element{}

      iex> get_element!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element!(id), do: Repo.get!(Element, id)

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

  @doc """
  Returns the list of annotations.

  ## Examples

      iex> list_annotations()
      [%Annotation{}, ...]

  """
  def list_annotations do
    Repo.all(Annotation)
  end

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
    annotation
    |> Annotation.changeset(attrs)
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
end

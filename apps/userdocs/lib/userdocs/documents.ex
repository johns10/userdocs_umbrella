defmodule UserDocs.Documents do
  @moduledoc """
  The Documents context.
  references: https://www.amberbit.com/blog/2019/4/16/composing-ecto-queries-filters-and-preloads/
  """

  import Ecto.Query, warn: false
  alias UserDocs.Repo
  alias UserDocs.Subscription

  alias UserDocs.Documents.Content

  def load_content(state, opts) do
    StateHandlers.load(state, list_content(opts[:params], opts[:filters]), Content, opts)
  end

  @doc """
  Returns the list of content.

  ## Examples

      iex> list_content()
      [%Content{}, ...]

  """
  def list_content(state, opts) when is_list(opts) do
    StateHandlers.list(state, Content, opts)
    |> maybe_preload_content(opts[:preloads], state, opts)
  end

  defp maybe_preload_content(content, nil, _, _), do: content
  defp maybe_preload_content(content, preloads, state, opts) do
    opts = Keyword.delete(opts, :filter)
    StateHandlers.preload(state, content, opts)
  end

  def list_content(params \\ %{}, filters \\ %{}) when is_map(params) and is_map(filters) do
    base_content_query()
    |> maybe_preload_content_versions(params[:content_versions])
    |> maybe_filter_by_team(filters[:team_id])
    |> Repo.all()
  end

  defp base_content_query(), do: from(content in Content)

  defp maybe_preload_content_versions(query, nil), do: query
  defp maybe_preload_content_versions(query, _), do: from(version in query, preload: [:content_versions])

  defp maybe_preload_content_versions(content, nil, _), do: content
  defp maybe_preload_content_versions(content, _, state) do
    content_versions =
      state.content_versions
      |> Enum.filter(fn(cv) -> cv.content_id == content.id end)

    content
    |> Map.put(:content_versions, content_versions)
  end

  defp maybe_filter_by_team(query, nil), do: query
  defp maybe_filter_by_team(query, team_id) do
    from(content in query,
      where: content.team_id == ^team_id
    )
  end

  @doc """
  Gets a single content.

  Raises `Ecto.NoResultsError` if the Content does not exist.

  ## Examples

      iex> get_content!(123)
      %Content{}

      iex> get_content!(456)
      ** (Ecto.NoResultsError)

  """

  def get_content!(id, params \\ %{}, filters \\ %{})
  def get_content!(id, params, filters) when is_map(params) and is_map(filters) do
    Repo.get!(Content, id)
  end
  def get_content!(id, state, opts) when is_list(opts) do
    StateHandlers.get(state, id, Content, opts)
    |> maybe_preload_content(opts[:preloads], state, opts)
  end



  @doc """
  Creates a content.

  ## Examples

      iex> create_content(%{field: value})
      {:ok, %Content{}}

      iex> create_content(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_content(attrs \\ %{}) do
    %Content{}
    |> Content.changeset(attrs)
    |> Repo.insert()
    |> Subscription.broadcast("content", "create")
  end

  @doc """
  Updates a content.

  ## Examples

      iex> update_content(content, %{field: new_value})
      {:ok, %Content{}}

      iex> update_content(content, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_content(%Content{} = content, attrs) do
    content
    |> Content.changeset(attrs)
    |> Repo.update()
    |> Subscription.broadcast("content", "update")
  end

  @doc """
  Deletes a content.

  ## Examples

      iex> delete_content(content)
      {:ok, %Content{}}

      iex> delete_content(content)
      {:error, %Ecto.Changeset{}}

  """
  def delete_content(%Content{} = content) do
    Repo.delete(content)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking content changes.

  ## Examples

      iex> change_content(content)
      %Ecto.Changeset{data: %Content{}}

  """
  def change_content(%Content{} = content, attrs \\ %{}) do
    Content.changeset(content, attrs)
  end

  alias UserDocs.Documents.Document

  def get_document!(id, state, opts) when is_integer(id) and is_list(opts) do
    StateHandlers.get(state, id, Document, opts)
    |> maybe_preload_document(opts[:preloads], state, opts)
  end
  def get_document!(id, params \\ %{}, filters \\ %{}) when is_map(params) and is_map(filters) do
    base_document_query(id)
    |> maybe_preload_document_versions(params[:document_versions])
    |> Repo.one!()
  end

  defp base_document_query(id) do
    from(document in Document, where: document.id == ^id)
  end

  def load_documents(state, opts) do
    StateHandlers.load(state, list_documents(%{}, opts[:filters]), Document, opts)
  end

  def list_documents(state, opts) when is_list(opts) do
    StateHandlers.list(state, Document, opts)
    |> maybe_preload_document(opts[:preloads], state, opts)
  end
  def list_documents(params \\ %{}, filters \\ %{}) when is_map(params) and is_map(filters) do
    base_documents_query()
    |> maybe_filter_by_project_id(filters[:project_id])
    |> Repo.all()
  end

  defp maybe_filter_by_project_id(query, nil), do: query
  defp maybe_filter_by_project_id(query, project_id) do
    from(document in query,
      where: document.project_id == ^project_id,
      order_by: document.name
    )
  end

  defp maybe_preload_document_versions(query, nil), do: query
  defp maybe_preload_document_versions(query, _), do: from(document in query, preload: [:document_versions])

  defp maybe_preload_document(documents, nil, _, _), do: documents
  defp maybe_preload_document(documents, preloads, state, opts) do
    opts = Keyword.delete(opts, :filter)
    StateHandlers.preload(state, documents, preloads, opts)
  end

  defp base_documents_query(), do: from(documents in Document)

  def create_document(attrs) do
    %Document{}
    |> Document.changeset(attrs)
    |> Repo.insert()
  end

  def update_document(%Document{} = document, attrs) do
    document
    |> Document.changeset(attrs)
    |> Repo.update()
  end

  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  def change_document(%Document{} = document, attrs \\ %{}) do
    Document.changeset(document, attrs)
  end

  alias UserDocs.Documents.DocumentVersion
  alias UserDocs.Documents.Docubit

  def load_document_versions(state, opts) do
    StateHandlers.load(state, list_document_versions(%{}, opts[:filters]), DocumentVersion, opts)
  end

  @doc """
  Returns the list of document_versions.

  ## Examples

      iex> list_document_versions()
      [%DocumentVersion{}, ...]

  """

  #TODO: Refactor
  def list_document_versions(state, opts) when is_list(opts) do
    StateHandlers.list(state, DocumentVersion, opts)
    |> maybe_preload_document_version(opts[:preloads], state, opts)
  end
  def list_document_versions(params \\ %{}, filters \\ %{}) when is_map(params) and is_map(filters) do
    base_document_versions_query()
    |> maybe_preload_docubit(params[:body])
    |> Repo.all()
  end

  defp maybe_filter_document_versions_by_team(query, nil), do: query
  defp maybe_filter_document_versions_by_team(query, team_id) do
    from(document_version in query,
      left_join: version in assoc(document_version, :version),
      left_join: project in assoc(version, :project),
      where: project.team_id == ^team_id
    )
  end

  defp base_document_versions_query(), do: from(document_versions in DocumentVersion)

  defp maybe_preload_document_version(document_versions, nil, _, _), do: document_versions
  defp maybe_preload_document_version(document_versions, preloads, state, opts) do
    opts = Keyword.delete(opts, :filter)
    StateHandlers.preload(state, document_versions, opts)
  end

  @doc """
  Gets a single document_version.

  Raises `Ecto.NoResultsError` if the Document does not exist.

  ## Examples

      iex> get_document_version!(123)
      %DocumentVersion{}

      iex> get_document_version!(456)
      ** (Ecto.NoResultsError)

  """
  def get_document_version!(id, state, opts) when is_list(opts) do
    StateHandlers.get(state, id, DocumentVersion, opts)
    |> maybe_preload_document_version(opts[:preloads], state, opts)
  end
  def get_document_version!(id, params \\ %{}, filters \\ %{}) when is_map(params) and is_map(filters) do
    base_document_version_query(id)
    |> maybe_preload_version(params[:version])
    |> maybe_preload_docubit(params[:body])
    |> maybe_preload_docubits(params[:docubits])
    |> Repo.one!()
  end

  defp maybe_preload_document_version(document_versions, nil, _, _), do: document_versions
  defp maybe_preload_document_version(document_versions, _preloads, state, opts) do
    opts = Keyword.delete(opts, :filter)
    StateHandlers.preload(state, document_versions, opts)
  end

  defp maybe_preload_version(query, nil), do: query
  defp maybe_preload_version(query, _), do: from(document_version in query, preload: [:version])

  defp maybe_preload_docubit(query, nil), do: query
  defp maybe_preload_docubit(query, _), do: from(document_version in query, preload: [:body])

  defp base_document_version_query(id) do
    from(document_version in DocumentVersion, where: document_version.id == ^id)
  end

  @doc """
  Creates a document_version.

  ## Examples

      iex> create_document_version(%{field: value})
      {:ok, %DocumentVersion{}}

      iex> create_document_version(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_document_version(attrs \\ %{})
  def create_document_version(attrs) do
    %DocumentVersion{}
    |> DocumentVersion.changeset(attrs)
    |> Repo.insert()
    |> check_default_body()
  end

  def check_default_body({ :ok, %DocumentVersion{ body: %Docubit{ document_version_id: nil } = docubit } = document_version }) do
    { :ok, docubit } = update_docubit(docubit, %{ document_version_id: document_version.id })
    { :ok, Map.put(document_version, :body, docubit ) }
  end
  def check_default_body(state), do: state

  @doc """
  Updates a document_version.

  ## Examples

      iex> update_document_version(document_version, %{field: new_value})
      {:ok, %DocumentVersion{}}

      iex> update_document_version(document_version, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_document_version(%DocumentVersion{} = document_version, attrs) do
    document_version
    |> DocumentVersion.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a document_version.

  ## Examples

      iex> delete_document_version(document_version)
      {:ok, %DocumentVersion{}}

      iex> delete_document_version(document_version)
      {:error, %Ecto.Changeset{}}

  """
  def delete_document_version(%DocumentVersion{} = document_version) do
    Repo.delete(document_version)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking document version changes.

  ## Examples

      iex> change_document_version(document_version)
      %Ecto.Changeset{data: %DocumentVersion{}}

  """
  def change_document_version(%DocumentVersion{} = document_version, attrs \\ %{}) do
    DocumentVersion.changeset(document_version, attrs)
  end

  alias UserDocs.Documents.ContentVersion

  def load_content_version(state, opts) do
    StateHandlers.load(state, list_content_versions(%{}, opts[:filters]), ContentVersion, opts)
  end

  @doc """
  Returns the list of content_versions.

  ## Examples

      iex> list_content_versions()
      [%ContentVersion{}, ...]

  """
  def list_content_versions(params \\ %{}, filters \\ %{}) do
    base_content_version_query()
    |> maybe_filter_by_content_id(filters[:content_id])
    |> maybe_filter_by_version_id(filters[:version_id])
    |> maybe_preload_language_code(params[:language_code])
    |> maybe_filter_by_team_id(filters[:team_id])
    |> Repo.all()
  end

  defp maybe_preload_language_code(query, nil), do: query
  defp maybe_preload_language_code(query, _), do: from(version in query, preload: [:language_code])

  defp maybe_filter_by_content_ids(query, nil), do: query
  defp maybe_filter_by_content_ids(query, content_ids) do
    from(content in query,
      where: content.content_id in ^content_ids
    )
  end

  defp maybe_filter_by_content_id(query, nil), do: query
  defp maybe_filter_by_content_id(query, content_id) do
    from(content in query,
      where: content.content_id == ^content_id
    )
  end

  defp maybe_filter_by_version_id(query, nil), do: query
  defp maybe_filter_by_version_id(query, version_id) do
    from(content_version in query,
      where: content_version.version_id == ^version_id
    )
  end

  defp maybe_filter_by_team_id(query, nil), do: query
  defp maybe_filter_by_team_id(query, team_id) do
    from(content_version in query,
      left_join: content in UserDocs.Documents.Content, on: content.id == content_version.content_id,
      left_join: team in UserDocs.Users.Team, on: team.id == content.team_id,
      where: team.id == ^team_id)
  end

  defp base_content_version_query(), do: from(content_versions in ContentVersion)

  @doc """
  Gets a single content_version.

  Raises `Ecto.NoResultsError` if the Content version does not exist.

  ## Examples

      iex> get_content_version!(123)
      %ContentVersion{}

      iex> get_content_version!(456)
      ** (Ecto.NoResultsError)

  """
  def get_content_version!(id, _params \\ %{}, _filters \\ %{})
  def get_content_version!(id, params, filters) when is_map(params) and is_map(filters) do
    Repo.get!(ContentVersion, id)
  end
  def get_content_version!(id, _params, _filters, state) when is_integer(id) do
    UserDocs.State.get!(state, id, :content_versions, ContentVersion)
  end

  @doc """
  Creates a content_version.

  ## Examples

      iex> create_content_version(%{field: value})
      {:ok, %ContentVersion{}}

      iex> create_content_version(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_content_version(attrs \\ %{}) do
    %ContentVersion{}
    |> ContentVersion.changeset(attrs)
    |> Repo.insert()
    |> Subscription.broadcast("content_version", "create")
  end

  @doc """
  Updates a content_version.

  ## Examples

      iex> update_content_version(content_version, %{field: new_value})
      {:ok, %ContentVersion{}}

      iex> update_content_version(content_version, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_content_version(%ContentVersion{} = content_version, attrs) do
    content_version
    |> ContentVersion.changeset(attrs)
    |> Repo.update()
    |> Subscription.broadcast("content_version", "update")
  end

  @doc """
  Deletes a content_version.

  ## Examples

      iex> delete_content_version(content_version)
      {:ok, %ContentVersion{}}

      iex> delete_content_version(content_version)
      {:error, %Ecto.Changeset{}}

  """
  def delete_content_version(%ContentVersion{} = content_version) do
    content_version
    |> Repo.delete()
    |> Subscription.broadcast("content_version", "delete")
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking content_version changes.

  ## Examples

      iex> change_content_version(content_version)
      %Ecto.Changeset{data: %ContentVersion{}}

  """
  def change_content_version(%ContentVersion{} = content_version, attrs \\ %{}) do
    ContentVersion.changeset(content_version, attrs)
  end

  alias UserDocs.Documents.LanguageCode

  def load_language_codes(state, opts) do
    StateHandlers.load(state, list_language_codes(), LanguageCode, opts)
  end

  def list_language_codes(state, opts) when is_list(opts) do
    StateHandlers.list(state, LanguageCode, opts)
  end

  @doc """
  Returns the list of language_codes.

  ## Examples

      iex> list_language_codes()
      [%LanguageCode{}, ...]

  """
  def list_language_codes do
    Repo.all(LanguageCode)
  end

  @doc """
  Gets a single language_code.

  Raises `Ecto.NoResultsError` if the Language code does not exist.

  ## Examples

      iex> get_language_code!(123)
      %LanguageCode{}

      iex> get_language_code!(456)
      ** (Ecto.NoResultsError)

  """
  def get_language_code!(id), do: Repo.get!(LanguageCode, id)

  @doc """
  Creates a language_code.

  ## Examples

      iex> create_language_code(%{field: value})
      {:ok, %LanguageCode{}}

      iex> create_language_code(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_language_code(attrs \\ %{}) do
    %LanguageCode{}
    |> LanguageCode.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a language_code.

  ## Examples

      iex> update_language_code(language_code, %{field: new_value})
      {:ok, %LanguageCode{}}

      iex> update_language_code(language_code, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_language_code(%LanguageCode{} = language_code, attrs) do
    language_code
    |> LanguageCode.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a language_code.

  ## Examples

      iex> delete_language_code(language_code)
      {:ok, %LanguageCode{}}

      iex> delete_language_code(language_code)
      {:error, %Ecto.Changeset{}}

  """
  def delete_language_code(%LanguageCode{} = language_code) do
    Repo.delete(language_code)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking language_code changes.

  ## Examples

      iex> change_language_code(language_code)
      %Ecto.Changeset{data: %LanguageCode{}}

  """
  def change_language_code(%LanguageCode{} = language_code, attrs \\ %{}) do
    LanguageCode.changeset(language_code, attrs)
  end

  alias UserDocs.Documents.Docubit

  def load_docubits(state, opts) do
    StateHandlers.load(state, list_docubits(%{}, opts[:filters]), opts)
  end

  def list_docubits(state, opts) when is_list(opts) do
    StateHandlers.list(state, Docubit, opts)
    |> maybe_preload_docubit(opts[:preloads], state, opts)
  end
  def list_docubits(params \\ %{}, filters \\ %{}) when is_map(params) and is_map(filters) do
    base_docubits_query()
    |> maybe_filter_by_document_id(filters[:project_id])
    |> Repo.all()
  end

  defp maybe_preload_docubit(docubits, nil, _, _), do: docubits
  defp maybe_preload_docubit(docubits, preloads, state, opts) do
    opts = Keyword.delete(opts, :filter)
    StateHandlers.preload(state, docubits, preloads, opts)
  end

  defp maybe_filter_by_document_id(query, nil), do: query
  defp maybe_filter_by_document_id(query, document_id) do
    from(item in query,
      where: item.document_id == ^document_id
    )
  end

  defp base_docubits_query(), do: from(docubits in Docubit)


  def get_docubit!(id, state, opts) when is_integer(id) and is_list(opts) do
    StateHandlers.get(state, id, Docubit, opts)
    |> maybe_preload_docubit(opts[:preloads], state, opts)
  end

  def get_docubit!(id, params \\ %{}, filters \\ %{}) when is_map(params) and is_map(filters) do
    base_docubit_query(id)
    |> maybe_preload_docubits(params[:docubits])
    |> maybe_preload_docubit_type(params[:docubit_type])
    |> Repo.one!()
  end

  defp maybe_preload_docubits(query, nil), do: query
  defp maybe_preload_docubits(query, _), do: from(docubit in query, preload: [:docubits])

  defp maybe_preload_docubit_type(query, nil), do: query
  defp maybe_preload_docubit_type(query, _), do: from(docubit in query, preload: [:docubit_type])


  defp base_docubit_query(id) do
    from(docubit in Docubit, where: docubit.id == ^id)
  end

  defp maybe_preload_docubit(docubits, nil, _, _), do: docubits
  defp maybe_preload_docubit(docubits, _preloads, state, opts) do
    opts = Keyword.delete(opts, :filter)
    StateHandlers.preload(state, docubits, opts)
  end

  def create_docubit(attrs \\ %{}) do
    %Docubit{}
    |> Docubit.changeset(attrs)
    |> Repo.insert()
  end

  def change_docubit(%Docubit{} = docubit, attrs \\ %{}) do
    Docubit.changeset(docubit, attrs)
  end
  def delete_docubit(%Docubit{} = docubit) do
    Repo.delete(docubit)
  end

  def delete_docubit_from_docubits(%Docubit{} = docubit, attrs) do
    case update_docubit_internal(docubit, attrs) do
      { :ok, updated_docubit } ->
        ids = Enum.map(updated_docubit.docubits, fn(d) -> d.id end)
        {
          docubit.docubits
          |> Enum.filter(fn(d) -> d.id not in ids end)
          |> Enum.at(0),
          updated_docubit
        }
      { :error, changeset } -> { :error, changeset }
      _ -> raise(RuntimeError, "delete_docubit_from_docubits failed")

    end
  end

  def update_docubit_internal(%Docubit{} = docubit, attrs) do
    docubit
    |> Docubit.internal_changeset(attrs)
    |> Repo.update()
  end

  def update_docubit(%Docubit{} = docubit, attrs) do
    docubit
    |> Docubit.changeset(attrs)
    |> Repo.update()
  end

  alias UserDocs.Documents.DocubitType

  def load_docubit_types(state, opts) do
    StateHandlers.load(state, list_docubit_types(), opts)
  end

  def list_docubit_types(state, opts) when is_list(opts) do
    StateHandlers.list(state, DocubitType, opts)
  end
  def list_docubit_types(params \\ %{}, filters \\ %{}) when is_map(params) and is_map(filters) do
    base_docubit_types_query()
    |> Repo.all()
  end

  defp base_docubit_types_query(), do: from(docubit_types in DocubitType)

  def get_docubit_type!(name) when is_bitstring(name) do
    base_docubit_types_query()
    |> filter_by_name(name)
    |> Repo.all()
    |> Enum.at(0)
  end
  def get_docubit_type_by_name!(state, name, opts) when is_bitstring(name) and is_list(opts) do
    list_docubit_types(state, opts)
    |> Enum.filter(fn(dt) -> dt.name == name end)
    |> Enum.at(0)
  end
  def get_docubit_type_by_id!(id, state, opts) when is_list(opts) do
  list_docubit_types(state, opts)
  |> Enum.filter(fn(dt) -> dt.id == id end)
  |> Enum.at(0)
  end

  defp filter_by_name(query, name) do
    from(docubit_type in query,
      where: docubit_type.name == ^name
    )
  end

  def get_docubit_type!(id, params \\ %{}, filters \\ %{}) when is_map(params) and is_map(filters) do
    base_docubit_type_query(id)
    |> Repo.one!()
  end

  defp base_docubit_type_query(id) do
    from(docubit_type in DocubitType, where: docubit_type.id == ^id)
  end

  def create_docubit_type(attrs \\ %{}) do
    %DocubitType{}
    |> DocubitType.changeset(attrs)
    |> Repo.insert()
  end

  def update_docubit_type(%DocubitType{} = docubit_type, attrs) do
    docubit_type
    |> DocubitType.changeset(attrs)
    |> Repo.update()
  end

  def update_all_docubit_types() do
    list_docubit_types()
    |> Enum.each(fn(dt) ->
        attrs_fun = dt.name <> "_attrs" |> String.to_atom()
        attrs = Kernel.apply(UserDocs.Documents.DocubitType, attrs_fun, [])
        { :ok, docubit_type } = update_docubit_type(dt, attrs)
      end)
  end

  def change_docubit_type(%DocubitType{} = docubit_type, attrs \\ %{}) do
    DocubitType.changeset(docubit_type, attrs)
  end

  def delete_docubit_type(%DocubitType{} = docubit_type) do
    Repo.delete(docubit_type)
  end

end

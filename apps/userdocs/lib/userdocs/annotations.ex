defmodule UserDocs.Annotations do
  @moduledoc """
  The Annotations context.
  """
  import Ecto.Query, warn: false
  alias UserDocs.Repo

  alias UserDocs.Annotations.Annotation

  def load_annotations(state, opts) do
    StateHandlers.load(state, list_annotations(opts[:params], opts[:filters]), Annotation, opts)
  end

  def list_annotations(params \\ %{}, filters \\ %{})
  def list_annotations(state, opts) when is_list(opts) do
    StateHandlers.list(state, Annotation, opts)
    |> maybe_preload_annotation(opts[:preloads], state, opts)
  end
  def list_annotations(params, filters) when is_map(params) and is_map(filters) do
    base_annotation_query()
    |> maybe_filter_annotation_by_page(filters[:page_id])
    |> maybe_filter_annotation_by_team_id(filters[:team_id])
    |> maybe_filter_annotation_by_project(filters[:project_id])
    |> maybe_preload_annotation_type(params[:annotation_type])
    |> order_by(:name)
    |> Repo.all()
  end

  def base_annotation_query(), do: from(annotations in Annotation)

  defp maybe_filter_annotation_by_page(query, nil), do: query
  defp maybe_filter_annotation_by_page(query, page_id) do
    from(annotation in query,
      where: annotation.page_id == ^page_id
    )
  end

  defp maybe_filter_annotation_by_team_id(query, nil), do: query
  defp maybe_filter_annotation_by_team_id(query, team_id) do
    from(annotation in query,
      left_join: page in UserDocs.Web.Page, on: page.id == annotation.page_id,
      left_join: project in UserDocs.Projects.Project, on: page.project_id == project.id,
      left_join: team in UserDocs.Users.Team, on: project.team_id == team.id,
      where: team.id == ^team_id)
  end

  defp maybe_filter_annotation_by_project(query, nil), do: query
  defp maybe_filter_annotation_by_project(query, project_id) do
    from(annotation in query,
      left_join: page in UserDocs.Web.Page, on: page.id == annotation.page_id,
      where: page.project_id == ^project_id)
  end

  defp maybe_preload_annotation_type(query, nil), do: query
  defp maybe_preload_annotation_type(query, _), do: from(annotations in query, preload: [:annotation_type])
  defp maybe_preload_annotation_type(object, _, state) do
    annotation_type =
      state.annotation_types
      |> Enum.filter(fn(at) -> at.id == object.annotation_type_id end)
      |> Enum.at(0)

    object
    |> Map.put(:annotation_type, annotation_type)
  end

  def get_annotation!(id), do: Repo.get!(Annotation, id)
  def get_annotation!(%{ annotations: annotations }, id), do: get_annotation!(annotations, id)
  def get_annotation!(id, state, opts) when is_list(opts) do
    StateHandlers.get(state, id, Annotation, opts)
    |> maybe_preload_annotation(opts[:preloads], state, opts)
  end

  defp maybe_preload_annotation(annotation, nil, _, _), do: annotation
  defp maybe_preload_annotation(annotation, _preloads, state, opts) do
    opts = Keyword.delete(opts, :filter)
    StateHandlers.preload(state, annotation, opts)
  end

  def create_annotation(attrs \\ %{}) do
    %Annotation{}
    |> Annotation.changeset(attrs)
    |> Repo.insert()
  end

  def update_annotation(%Annotation{} = annotation, attrs) do
    changeset = Annotation.changeset(annotation, attrs)
    {status, annotation} = Repo.update(changeset)
    { status, annotation }
  end

  def delete_annotation(%Annotation{} = annotation) do
    Repo.delete(annotation)
  end

  def change_annotation(%Annotation{} = annotation, attrs \\ %{}) do
    Annotation.changeset(annotation, attrs)
  end
end

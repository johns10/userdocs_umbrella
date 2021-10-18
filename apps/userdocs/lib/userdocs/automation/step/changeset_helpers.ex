defmodule UserDocs.Automation.Step.Changeset do
  import Ecto.Changeset

  require Logger

  alias UserDocs.Documents
  alias UserDocs.Web
  alias UserDocs.Annotations.Annotation
  alias UserDocs.Web.Element
  alias UserDocs.Web.Page

  def handle_page_id_change(%{changes: %{page_id: page_id}} = changeset, state) do
    Logger.debug("Page id changed to #{page_id}")
    page = Web.get_page!(page_id, state, state.assigns.state_opts)
    Map.put(changeset.data, :page, page)
    |> cast(changeset.params, [])
  end
  def handle_page_id_change(changeset, _state), do: changeset

  def maybe_replace_page_params(changeset, %{changes: %{page_id: nil}}, _state) do
    params =
      changeset.params
      |> Map.put("page", nil)
      |> Map.put("page_id", nil)

    Map.put(changeset, :params, params)
  end
  def maybe_replace_page_params(changeset, %{changes: %{page_id: page_id}}, state) do
    Logger.debug("Replacing Page #{page_id} Params")
    page = Web.get_page!(page_id, state, state.assigns.state_opts)
    page_params = replace_params_with_fields(changeset.params["page"], page, Page)
    params =
      changeset.params
      |> Map.put("page", page_params)
      |> Map.put("page_id", Integer.to_string(page_id))

    Map.put(changeset, :params, params)
  end
  def maybe_replace_page_params(changeset, _last_changeset, _state), do: changeset

  def handle_annotation_id_change(%{changes: %{annotation_id: annotation_id}} = changeset, state) do
    Logger.debug("Annotation id changed to #{annotation_id}")
    opts = Keyword.put(state.assigns.state_opts, :preloads, [:annotation_type ])
    annotation = Web.get_annotation!(annotation_id, state, opts)

    Map.put(changeset.data, :annotation, annotation)
    |> cast(changeset.params, [])
  end
  def handle_annotation_id_change(changeset, _state), do: changeset

  def maybe_replace_annotation_params(changeset, %{changes: %{annotation_id: nil}}, _state) do
    params =
      changeset.params
      |> Map.put("annotation", nil)
      |> Map.put("annotation_id", nil)

    Map.put(changeset, :params, params)
  end
  def maybe_replace_annotation_params(changeset, %{changes: %{annotation_id: annotation_id}}, state) do
    Logger.debug("Replacing Annotation #{annotation_id} Params")
    opts = Keyword.put(state.assigns.state_opts, :preloads, [:annotation_type ])
    annotation = Web.get_annotation!(annotation_id, state, opts)
    annotation_params = replace_params_with_fields(changeset.params["annotation"], annotation, Annotation)
    params =
      changeset.params
      |> Map.put("annotation", annotation_params)
      |> Map.put("annotation_id", Integer.to_string(annotation_id))

    Map.put(changeset, :params, params)
  end
  def maybe_replace_annotation_params(changeset, _last_changeset, _state), do: changeset

  def handle_element_id_change(%{changes: %{element_id: element_id}} = changeset, state) do
    Logger.debug("Element id changed to #{element_id}")
    element = Web.get_element!(element_id, state, state.assigns.state_opts)
    Map.put(changeset.data, :element, element)
    |> cast(changeset.params, [])
  end
  def handle_element_id_change(changeset, _state) do
    changeset
    |> cast(changeset.params, [:page_id, :element_id, :annotation_id])
  end

  def maybe_replace_element_params(changeset, %{changes: %{element_id: nil}}, _state) do
    params =
      changeset.params
      |> Map.put("element", nil)
      |> Map.put("element_id", nil)

    Map.put(changeset, :params, params)
  end
  def maybe_replace_element_params(changeset, %{changes: %{element_id: element_id}}, state) do
    Logger.debug("Replacing Element params")
    element = Web.get_element!(element_id, state, state.assigns.state_opts)
    element_params = replace_params_with_fields(changeset.params["element"], element, Element)
    params =
      changeset.params
      |> Map.put("element", element_params)
      |> Map.put("element_id", Integer.to_string(element_id))

    Map.put(changeset, :params, params)
  end
  def maybe_replace_element_params(changeset, _last_changeset, _state), do: changeset

  def update_foreign_keys(changeset, action) do
    _log_string = """
      Updating Foreign Keys.
      Annotation ID: #{changeset.data.annotation_id}, param: #{changeset.params["annotation_id"]}
      Element ID: #{changeset.data.element_id}, param: #{changeset.params["element_id"]}
      Page ID: #{changeset.data.page_id}, param: #{changeset.params["page_id"]}
    """

    case action do
      :validate ->
        {:ok, step} = apply_action(changeset, :update)
        step
        |> cast(changeset.params, [])
      _ ->
        {:ok, step} = UserDocs.Repo.update(changeset)
        step
        |> cast(changeset.params, [])
    end
  end

  def replace_params_with_fields(nil, object, module) do
    replace_params_with_fields(%{}, object, module)
  end
  def replace_params_with_fields(params, nil, _module), do: params
  def replace_params_with_fields(params, object, module) do
    Enum.reduce(module.__schema__(:fields), params,
      fn(field, params) ->
        Map.put(params, to_string(field), Map.get(object, field))
      end
    )
  end

  def cast_changeset_params(changeset, allowed) do
    changeset
    |> cast(changeset.params, allowed)
  end
end

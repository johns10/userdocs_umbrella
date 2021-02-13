defmodule UserDocsWeb.Form do
  alias UserDocsWeb.DomainHelpers

  require Logger

  def parent_id(%{
    assigns: assigns,
    changeset: changeset,
    parent_id_field: parent_id_field
  }) do

    { :ok, parent_id } =
      { :nok, 0 }
      |> maybe_parent_id_from_assigns(assigns)
      |> maybe_parent_id_from_changeset(changeset, parent_id_field)
      |> default_parent_id()

    parent_id
  end

  defp maybe_parent_id_from_assigns({ :nok, _ }, %{ parent: %{ id: id }}) do
    { :ok, id }
  end
  defp maybe_parent_id_from_assigns(_, _), do: { :nok, nil}

  defp maybe_parent_id_from_changeset({ :nok, _ }, %{ data: data}, field) do
    { :ok, Map.get(data, field) }
  end
  defp maybe_parent_id_from_changeset({ :ok, value }, _, _), do: { :ok, value }
  defp maybe_parent_id_from_changeset(_, _, _), do: { :nok, nil}

  defp default_parent_id({:nok, _}), do: { :ok, 0 }
  defp default_parent_id(state), do: state

  def select_list(%{
    list: list,
    function: function,
    filter: filter,
    params: params
  }) do
    { :ok, select_list } =
      { :nok, [] }
      |> maybe_list(list)
      |> maybe_function(function, filter, params)
      |> DomainHelpers.select_list()

    select_list
  end

  def maybe_list({ :nok, _ }, list = [ _ | _ ]), do: list
  def maybe_list({ :nok, current_list }, _), do: current_list

  def maybe_function({ :ok, current_list }, _, _, _), do: { :ok, current_list }
  def maybe_function({ :nok, _ }, function, filter, params) do
    { :ok, function.(filter, params) }
  end

  def available_items(%{
    assigns: assigns,
    key: key,
    function: function,
    params: params,
    filter: filter
  }) do
    { :ok, available_items } =
      { :nok, [] }
      |> maybe_select_list_from_assigns(assigns, key, filter)
      |> select_list_from_domain(function, params, filter)
      |> DomainHelpers.select_list()

      available_items
  end

  def maybe_select_list_from_assigns({ :nok, list }, assigns, key, _filter) do
    try do
      result =
        Map.get(assigns.select_lists, key)
      { :ok, result }
    rescue
      _ -> { :nok, []}
    end
  end

  def select_list_from_domain({ :nok, _ }, function, params, filter)
  do

    { :ok, function.(params, filter) }
  end
  def select_list_from_domain({ :ok, list }, _, _, _), do: { :ok, list }

end

defmodule UserDocs.Documents.Docubit.Access do

  require Logger

  alias UserDocs.Documents.NewDocubit, as: Docubit
  alias UserDocs.Documents.Docubit.Type

  def get({ :error, docubit, errors}, _), do: { :error, docubit, errors}
  def get(%Docubit{ address: [0], type: %Type{ id: "container" }} = body, [0]), do: body
  def get(%Docubit{ address: [0], type: %Type{ id: "container" }} = body, [0 | address]) do
    Logger.debug("Getting Docubit at address #{inspect(address)}")
    body
    |> fetch(address)
    |> handle_fetch_response()
  end

  def delete({ :error, docubit, errors}, _), do: { :error, docubit, errors}
  def delete(_, [0], _docubit) do
    raise(RuntimeError, "Can't delete the document body")
  end
  def delete(
    %Docubit{ address: [0], type: %Type{ id: "container" }} = body,
    [ 0 | address ], docubit
  ) do
    Logger.debug("deleting docubit at address #{inspect(address)}")
    body
    |> fetch_and_replace(address, docubit, &apply_delete/3)
    |> handle_fetch_response()
  end

  def update({ :error, docubit, errors}, _), do: { :error, docubit, errors}
  def update(_, [0], _docubit) do
    raise(RuntimeError, "Can't update the document body")
  end
  def update(
    %Docubit{ address: [0], type: %Type{ id: "container" }} = body,
    [ 0 | address ], docubit
  ) do
    Logger.debug("Updating docubit #{docubit.type_id} at address #{inspect(address)}")
    body
    |> fetch_and_replace(address, docubit, &apply_update/3)
    |> handle_fetch_response()
  end

  def insert({ :error, docubit, errors}, _), do: { :error, docubit, errors}
  def insert(_, [0], _docubit) do
    raise(RuntimeError, "Can't replace the document body directly")
  end
  def insert(
    %Docubit{ address: [0], type: %Type{ id: "container" }} = body,
    [ 0 | inner_address ] = address, docubit
  ) do
    Logger.debug("Putting docubit #{docubit.type_id} at address #{inspect(address)}")
    body
    |> fetch_and_replace(inner_address, docubit, &apply_insert/3)
    |> handle_fetch_response()
  end

  defp apply_delete([ %Docubit{} | _ ] = docubits, index, new_docubit) do
    final_delete(docubits, index, new_docubit)
  end
  defp apply_delete([] = docubits, index, new_docubit) do
    final_delete(docubits, index, new_docubit)
  end
  defp final_delete(docubits, index, _) do
    docubits
    |> List.delete_at(index)
  end

  defp apply_insert([ %Docubit{} | _ ] = docubits, index, new_docubit) do
    final_insert(docubits, index, new_docubit)
  end
  defp apply_insert([] = docubits, index, new_docubit) do
    final_insert(docubits, index, new_docubit)
  end
  defp final_insert(docubits, index, new_docubit) do
    docubits
    |> List.insert_at(index, new_docubit)
  end

  defp apply_update([ %Docubit{} | _ ] = docubits, index, new_docubit) do
    final_insert(docubits, index, new_docubit)
  end
  defp apply_update([] = docubits, index, new_docubit) do
    final_insert(docubits, index, new_docubit)
  end
  defp final_update(docubits, index, new_docubit) do
    docubits
    |> List.update_at(index, fn(_) -> new_docubit end)
  end

  defp fetch_and_replace(docubit, [ index | [] ], new_docubit, final_op) do
    Logger.debug("Fetching Single Element from #{docubit.type_id} at index #{index}")

    address = List.insert_at(docubit.address, -1, index)

    with docubits <- Map.get(docubit, :docubits),
      docubits <- final_op.(docubits, index, Map.put(new_docubit, :address, address)),
      changeset <- Docubit.change_docubits(docubit, %{ docubits: docubits }),
      { status, updated_docubit } <- Ecto.Changeset.apply_action(changeset, :update)
    do
      case status do
        :error -> { status, docubit, updated_docubit.errors }
        :ok -> { status, updated_docubit, [] }
      end
    else
      _ -> raise(RuntimeError, "Docubit.fetch_and_replace (single) failed")
    end

  end
  defp fetch_and_replace(docubit, [ index | address ], new_docubit, final_op) do
    Logger.debug("Fetching Multi Element List from #{docubit.type_id} at address #{inspect(address)}")

    with docubits <- Map.get(docubit, :docubits),
      { :ok, located_docubit, [] } <- fetch(docubit, index),
      { status, updated_docubit, errors }
        <- fetch_and_replace(located_docubit, address, new_docubit, final_op),

      updated_docubits
        <- List.update_at(docubits, index, fn(_) -> updated_docubit end)
    do
      case status do
        :ok -> { :ok, Map.put(docubit, :docubits, updated_docubits), errors }
        :error -> { :error, docubit, errors }
      end
    else
      { :error, docubit, errors } -> { :error, docubit, errors }
      _ -> raise(RuntimeError, "Docubit.fetch_and_replace (multiple) failed")
    end
  end

  defp fetch(docubit, [ index | [] ]), do: fetch(docubit, index)
  defp fetch(docubit, [ index | address ]) do
    Logger.debug("Multi Element List: #{docubit.type_id}")
    with { :ok, located_docubit, [] } <- fetch(docubit, index),
      { :ok, located_docubit, [] } <- fetch(located_docubit, address)
    do
      { :ok, located_docubit, [] }
    else
      { :error, docubit, errors } -> { :error, docubit, errors }
    end
  end
  defp fetch(docubit, index) when is_integer(index) do
    Logger.debug("Single Element List: #{docubit.type_id}")
    with docubits <- Map.get(docubit, :docubits),
         located_docubit = %Docubit{} <- Enum.at(docubits, index, :error)
    do
      { :ok, located_docubit, [] }
    else
      :error -> { :error, docubit, [docubit: "Docubit not found at address #{index} on docubit #{inspect(docubit.address)}"] }
    end
  end

  defp handle_fetch_response({ status, docubit, errors }) do
    case status do
      :error -> { status, docubit, errors }
      :ok -> docubit
    end
  end
end

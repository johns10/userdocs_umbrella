defmodule UserDocs.Documents.Docubit.Hydrate do
  require Logger

  alias UserDocs.Documents
  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents.DocubitType
  alias UserDocs.Documents.Content
  alias UserDocs.Automation.Step
  alias UserDocs.Web.Annotation
  alias UserDocs.Media.Screenshot
  alias UserDocs.Media.File

  def apply(docubit, data) do
    with { :ok, [] } <- precheck(docubit, data),
      { :ok, docubit } <- hydrate(docubit, data)
    do
      docubit
    else
      { :error, _body, _errors } -> raise(RuntimeError, "Caught Access Error")
      { :precheck, errors } -> { :error, errors}
    end
  end

  def hydrate(
    %Docubit{ docubit_type: %DocubitType{ name: "p" }} = docubit,
    %Content{} = content
  ) do
    hydrate_with_content(docubit, content)
  end
  def hydrate(
    %Docubit{ docubit_type: %DocubitType{ name: "li" }} = docubit,
    %Content{} = content
  ) do
    hydrate_with_content(docubit, content)
  end
  def hydrate(
    %Docubit{ docubit_type: %DocubitType{ name: "info" }} = docubit,
    %Content{} = content
  ) do
    hydrate_with_content(docubit, content)
  end
  def hydrate(
    %Docubit{ docubit_type: %DocubitType{ name: "p" }} = docubit,
    %Annotation{} = annotation
  ) do
    hydrate_with_annotation(docubit, annotation)
  end
  def hydrate(
    %Docubit{ docubit_type: %DocubitType{ name: "li" }} = docubit,
    %Annotation{} = annotation
  ) do
    hydrate_with_annotation(docubit, annotation)
  end
  def hydrate(
    %Docubit{ docubit_type: %DocubitType{ name: "li" }} = docubit,
    %Step{} = step
  ) do
    hydrate_with_step(docubit, step)
  end
  def hydrate(
    %Docubit{ docubit_type: %DocubitType{ name: "p" }} = docubit,
    %Step{} = step
  ) do
    hydrate_with_step(docubit, step)
  end
  def hydrate(
    %Docubit{ docubit_type: %DocubitType{ name: "img" }} = docubit,
    %Step{ screenshot: %Screenshot{ file: %File{}}} = step
  ) do
    attrs = %{
      through_step_id: step.id,
      file_id: step.screenshot.file_id
    }
    docubit
    |> Documents.update_docubit(attrs)

    with {:ok, docubit} <- Documents.update_docubit(docubit, attrs),
      docubit <- Map.put(docubit, :screenshot, step.screenshot),
      docubit <- Map.put(docubit, :through_step, step)
    do
      { :ok, docubit }
    else
      { :error, changeset } -> changeset
    end
  end
  def hydrate(%Docubit{ docubit_type: %DocubitType{ name: docubit_type }}, object) do
    { :hydrate, "Hydrate Not Implemented for this combination: #{docubit_type} and #{inspect(object.__struct__)}"}
  end

  def hydrate_with_content(docubit = %Docubit{}, content = %Content{}) do
    attrs = %{
      content_id: content.id,
      content: content
    }
    with {:ok, docubit} <- Documents.update_docubit(docubit, attrs),
      docubit <- Map.put(docubit, :content, content)
    do
      { :ok, docubit }
    else
      { :error, changeset } -> changeset
    end
  end
  def hydrate_with_annotation(docubit = %Docubit{}, annotation = %Annotation{}) do
    attrs = %{
      through_annotation_id: annotation.id,
      content_id: annotation.content_id
    }
    with {:ok, docubit} <- Documents.update_docubit(docubit, attrs),
      docubit <- Map.put(docubit, :content, annotation.content),
      docubit <- Map.put(docubit, :through_annotation, annotation)
    do
      { :ok, docubit }
    else
      { :error, changeset } -> changeset
    end
  end
  def hydrate_with_step(docubit = %Docubit{}, step = %Step{}) do
    IO.puts("Hydrating with step")
    attrs = %{
      through_step_id: step.id,
      through_annotation_id: step.annotation.id,
      content_id: step.annotation.content_id,
    }
    with {:ok, docubit} <- Documents.update_docubit(docubit, attrs),
      docubit <- Map.put(docubit, :content, step.annotation.content),
      docubit <- Map.put(docubit, :through_annotation, step.annotation),
      docubit <- Map.put(docubit, :through_step, step)
    do
      { :ok, docubit }
    else
      { :error, changeset } -> changeset
    end
  end

  def precheck(docubit, data) do
    { :ok, [] }
    |> type?(docubit)
    |> allowed?(docubit, data)
    |> precheck_data(docubit.docubit_type.name, data)
  end

  def type?({ status, errors }, docubit) do
    case docubit.docubit_type_id != nil do
      true -> { status, errors }
      false -> { :precheck, Keyword.put(errors, :type, "Type not found in docubit")}
    end
  end

  def allowed?({ status, errors }, %Docubit{ docubit_type: %DocubitType{} } = docubit, data) do
    case data.__meta__.schema in docubit.docubit_type.allowed_data do
      true -> { status, errors }
      false ->
        {
          :precheck,
          Keyword.put(errors, :allowed,
            "#{inspect(data.__meta__.schema)} not allowed in #{docubit.docubit_type.name}")
        }
    end
  end
  def allowed?(_, %Docubit{ docubit_type: %Ecto.Association.NotLoaded{} }, _) do
    raise(RuntimeError, Atom.to_string(__MODULE__) <> " missing type (Not Loaded).")
  end

  #TODO: THis is dumb.  Remove
  def precheck_data(s, "p", %Annotation{} = a), do: precheck_annotation(s, a)
  def precheck_data(s, "p", %Content{} = _data), do: s
  def precheck_data(s, "p", %Step{} = step), do: precheck_step_p(s, step)
  def precheck_data(s, "li", %Annotation{} = a), do: precheck_annotation(s, a)
  def precheck_data(s, "li", %Content{} = _data), do: s
  def precheck_data(s, "li", %Step{} = step), do: precheck_step_p(s, step)
  def precheck_data(s, "info", %Content{} = _data), do: s
  def precheck_data(s, "img", %Step{} = step), do: precheck_step_img(s, step)
  def precheck_data(_, _, _), do: { :precheck, [ "Data not allowed in docubit"]}

  def precheck_annotation({ status, errors }, annotation) do
    { status, errors }
    |> annotation_has_content_id?(annotation)
    |> annotation_has_content?(annotation)
  end

  def precheck_step_p({ status, errors }, step) do
    { status, errors }
    |> step_has_annotation?(step)
    |> annotation_has_content?(step.annotation)
  end

  def precheck_step_img({ status, errors }, step) do
    { status, errors }
    |> step_has_screenshot?(step)
  end

  def annotation_has_content_id?({ status, errors }, annotation) do
    check({ status, errors },
      is_integer(Map.get(annotation, :content_id, nil)),
      :annotation, "Content ID not found in annotation")
  end

  def annotation_has_content?({ status, errors }, %{ content: %Content{}}) do
    { status, errors }
  end
  def annotation_has_content?({ _, errors }, %{ content: _ }) do
    { :precheck, Keyword.put(errors, :content, "Content not found in annotation") }
  end

  def step_has_annotation?({ status, errors }, %{ annotation: %Annotation{}}) do
    { status, errors }
  end
  def step_has_annotation?({ _, errors }, %{ annotation: _ }) do
    { :precheck, Keyword.put(errors, :annotation, "Annotation not found in step") }
  end

  def step_has_screenshot?({ status, errors }, %{ screenshot: %Screenshot{}}) do
    { status, errors }
  end
  def step_has_screenshot?({ _, errors }, %{ screenshot: _ }) do
    { :precheck, Keyword.put(errors, :screenshot, "Screenshot not found in step") }
  end

  def check({ status, errors }, bool, key, message) do
    case bool do
      true -> { status, errors }
      false -> { :precheck, Keyword.put(errors, key, message)}
    end
  end
end

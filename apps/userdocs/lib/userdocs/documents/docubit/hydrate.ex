defmodule UserDocs.Documents.Docubit.Hydrate do

  import Ecto.Changeset

  require Logger

  alias UserDocs.Documents.Docubit, as: Docubit
  alias UserDocs.Documents.Content
  alias UserDocs.Automation.Step
  alias UserDocs.Documents.Docubit.Access
  alias UserDocs.Web.Annotation
  alias UserDocs.Media.Screenshot
  alias UserDocs.Media.File

  def apply(body, address, data) do
    with docubit <- Access.get(body, address),
      { :ok, [] } <- precheck(docubit, data),
      { :ok, docubit } <- hydrate(docubit, data),
      body <- Access.insert(body, address, docubit)
    do
      body
    else
      { :error, _body, _errors } -> raise(RuntimeError, "Caught Access Error")
      { :precheck, errors } -> { :error, errors}
    end
  end

  def hydrate(
    %Docubit{ type_id: "p"} = docubit,
    %Content{} = content
  ) do
    attrs = %{
      content_id: content.id,
      content: content
    }
    docubit
    |> Docubit.changeset(attrs)
    |> apply_action(:update)
  end
  def hydrate(
    %Docubit{ type_id: "p"} = docubit,
    %Annotation{} = annotation
  ) do
    attrs = %{
      through_annotation_id: annotation.id,
      through_annotation: annotation,
      content_id: annotation.content_id,
      content: annotation.content
    }
    docubit
    |> Docubit.changeset(attrs)
    |> apply_action(:update)
  end
  def hydrate(
    %Docubit{ type_id: "p"} = docubit,
    %Step{} = step
  ) do
    attrs = %{
      through_step_id: step.id,
      through_step: step,
      through_annotation_id: step.annotation.id,
      through_annotation: step.annotation,
      content_id: step.annotation.content_id,
      content: step.annotation.content
    }
    docubit
    |> Docubit.changeset(attrs)
    |> apply_action(:update)
  end
  def hydrate(
    %Docubit{ type_id: "img"} = docubit,
    %Step{} = step
  ) do
    attrs = %{
      through_step_id: step.id,
      through_step: step,
      file_id: step.screenshot.file_id,
      file: step.screenshot.file
    }
    docubit
    |> Docubit.changeset(attrs)
    |> apply_action(:update)
  end
  def hydrate(_, _) do
    { :hydrate, "Hydrate Not Implemented for this combination"}
  end

  def precheck(docubit, data) do
    { :ok, [] }
    |> type?(docubit)
    |> allowed?(docubit, data)
    |> precheck_data(docubit.type_id, data)
  end

  def type?({ status, errors }, docubit) do
    case docubit.type != nil do
      true -> { status, errors }
      false -> { :precheck, Keyword.put(errors, :type, "Type not found in docubit")}
    end
  end

  def allowed?({ status, errors }, docubit, data) do
    case data.__meta__.schema in docubit.type.allowed_data do
      true -> { status, errors }
      false ->
        {
          :precheck,
          Keyword.put(errors, :allowed,
            "#{inspect(data.__meta__.schema)} not allowed in #{docubit.type_id}")
        }
    end
  end

  def precheck_data(s, "p", %Annotation{} = a), do: precheck_annotation(s, a)
  def precheck_data(s, "p", %Content{} = _data), do: s
  def precheck_data(s, "p", %Step{} = step), do: precheck_step_p(s, step)
  def precheck_data(s, "img", %Step{} = step), do: precheck_step_img(s, step)
  def precheck_data(_, _, _), do: false

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
    IO.inspect(step)
    { status, errors }
    |> step_has_screenshot?(step)
    |> screenshot_has_file?(step.screenshot)
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

  def screenshot_has_file?({ status, errors }, %{ file: %File{}}) do
    { status, errors }
  end
  def screenshot_has_file?({ _, errors }, %{ file: _ }) do
    { :precheck, Keyword.put(errors, :file, "File not found in Screenshot") }
  end

  def check({ status, errors }, bool, key, message) do
    case bool do
      true -> { status, errors }
      false -> { :precheck, Keyword.put(errors, key, message)}
    end
  end
end

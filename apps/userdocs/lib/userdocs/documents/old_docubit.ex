defmodule UserDocs.Documents.DocuBit do
  @hard_coded_path_hack "http://localhost:4000/images/"

  require Logger

  alias UserDocs.Automation.Step
  alias UserDocs.Automation.StepType
  alias UserDocs.Web.Annotation
  alias UserDocs.Web.AnnotationType
  alias UserDocs.Documents.Content
  alias UserDocs.Documents.ContentVersion

  defstruct(
    type: :blank,
    data: %{},
    children: []
  )

  @moduledoc """
  The parse function will take a map and turn it into a nested map of
  Docubits.
  """
  def parse(nil, _socket) do
    raise(ArgumentError, "UserDocs.Documents.DocuBit.parse/2 was passed a nil docubit.")
  end
  def parse(%{"children" => children, "data" => data, "type" => type}, socket) do
    parse(%{
      children: children,
      data: data,
      type: type
    }, socket)
  end
  def parse(%{children: children, data: data, type: type = "annotation"}, socket) do
    # Logger.debug("Parsing an docubit for annotation #{data["id"]}")

    annotation =
      Enum.filter(socket.assigns.annotation, fn(i) -> i.id == data["id"] end)
      |> Enum.at(0)

    prepared_data =
      %{ }
      |> Map.put(:id, data["id"])
      |> Map.put(:current_language_code_id, socket.assigns.current_language_code.id)
      |> prepare(annotation)

    %UserDocs.Documents.DocuBit{
      type: type,
      data: prepared_data,
      children: Enum.map(children, &parse(&1, socket))
    }
  end
  def parse(%{children: children, data: data, type: type = "step"}, socket) do
    # Logger.debug("Parsing an docubit for step #{data["id"]}")

    step =
      Enum.filter(socket.assigns.step, fn(i) -> i.id == data["id"] end)
      |> Enum.at(0)

    prepared_data =
      %{ }
      |> Map.put(:id, data["id"])
      |> Map.put(:current_language_code_id, socket.assigns.current_language_code.id)
      |> prepare(step)

    %UserDocs.Documents.DocuBit{
      type: update_step_docubit_type(step, type),
      data: prepared_data,
      children: Enum.map(children, &parse(&1, socket))
    }
  end
  def parse(%{children: children, data: data, type: type = "content"}, socket) do
    Logger.debug("Parsing an docubit for content #{data["id"]}")

    content =
      Enum.filter(socket.assigns.content, fn(c) -> c.id == data["id"] end)
      |> Enum.at(0)

    prepared_data =
      %{ }
      |> Map.put(:id, data["id"])
      |> Map.put(:current_language_code_id, socket.assigns.current_language_code.id)
      |> prepare(content)

    %UserDocs.Documents.DocuBit{
      type: type,
      data: prepared_data,
      children: Enum.map(children, &parse(&1, socket))
    }
  end
  def parse(%{children: children, data: data, type: type = "column"}, socket) do
    # Logger.debug("Parsing a #{type} docubit")
    %UserDocs.Documents.DocuBit{
      type: type,
      data: data,
      children: Enum.map(children, &parse(&1, socket))
    }
  end
  def parse(%{children: children, data: data, type: type = "add_column"}, socket) do
    # Logger.debug("Parsing a #{type} docubit")
    %UserDocs.Documents.DocuBit{
      type: type,
      data: data,
      children: Enum.map(children, &parse(&1, socket))
    }
  end
  def parse(%{children: children, data: data, type: type = "row"}, socket) do
    # Logger.debug("Parsing a #{type} docubit")
    %UserDocs.Documents.DocuBit{
      type: type,
      data: data,
      children: Enum.map(children, &parse(&1, socket))
    }
  end
  def parse(%{children: children, data: data, type: type}, socket) do
    Logger.warn("Parsing an uncaught #{type} docubit")

    %UserDocs.Documents.DocuBit{
      type: type,
      data: data,
      children: Enum.map(children, &parse(&1, socket))
    }
  end

  defp update_step_docubit_type(%Step{
    step_type: %StepType{ name: "Apply Annotation" }}, _type
  ) do
    "annotation"
  end
  defp update_step_docubit_type(%Step{}, type), do: type


  def prepare(data, %Step{
    step_type: %StepType{name: "Apply Annotation"},
    annotation: %Annotation{} = annotation
  }) do
    Logger.debug("Preparing a step that applies an annotation")
    prepare(data, annotation)
  end
  def prepare(_data, %Annotation{ id: id,
    annotation_type: %AnnotationType{ name: annotation_type_name },
    content: nil
  }) do
    Logger.warn("Preparing an annotation step that has no content")
    %{
      id: id,
      type: annotation_type_name,
      error_code: "NoContent",
      error_message: "Annotation has no content, add content to annotation"
    }
  end
  def prepare(data, annotation = %Annotation{
    annotation_type: %AnnotationType{ name: annotation_type_name },
    content: %Content{
      content_versions: [ %ContentVersion{} | _ ] = content_versions
    }
  }) do
    content_version =
      content_versions
      |> Enum.filter(fn(cv) ->
          cv.language_code_id == data.current_language_code_id
        end)
      |> Enum.at(0)
      |> maybe_nil_content_version()

    label = annotation.label

    log_string = "Prepared a #{annotation_type_name} annotation #{label}: #{content_version.body}"
    Logger.debug(log_string)

    data
    |> Map.put(:type, annotation_type_name)
    |> Map.put(:label, annotation.label)
    |> Map.put(:body, content_version.body)
  end
  def prepare(_, %Content{ id: id, content_versions: [ ] }) do
    Logger.warn("Preparing a content that has no content_versions")
    %{
      id: id,
      type: "content",
      error_code: "NoContentVersions",
      error_message: "Content has no content versions, please add some"
    }
  end
  def prepare(data, content = %Content{
    content_versions: [ %ContentVersion{} | _ ] = content_versions
  }) do
    Logger.debug("Preparing a content")
    content_version =
      content_versions
      |> Enum.filter(fn(cv) ->
          cv.language_code_id == data.current_language_code_id
        end)
      |> Enum.at(0)
      |> maybe_nil_content_version()

    log_string = "Prepared content #{content.id}: #{content_version.body}"
    Logger.debug(log_string)

    data
    |> Map.put(:title, content.name)
    |> Map.put(:type, "content")
    |> Map.put(:body, content_version.body)
  end
  def prepare(data, %Step{step_type: %StepType{name: name}, screenshot: screenshot}) do
    prepare(data, name, screenshot)
  end
  def prepare(data, _, nil) do
    Logger.debug("Preparing a step with a nil screenshot")

    data
    |> Map.put(:type, "image")
    |> Map.put(:image_url, "https://www.iconfinder.com/data/icons/image-1/64/Image-12-512.png")
  end
  def prepare(data, _name, screenshot) do
    Logger.debug("Preparing a step with a screenshot")

    data
    |> Map.put(:type, "image")
    |> Map.put(:image_url, @hard_coded_path_hack <> screenshot.file.filename)

  end
  def prepare(_data, nil) do
    Logger.warn("Preparing a nil docubit")
    %{type: "nil", id: "", body: "Failed to fetch body"}
  end
  def prepare(_data, _payload) do
    Logger.warn("Preparing an unhandled docubit")
    %{type: "nil", id: "", body: "Failed to handle docubit"}
  end

  def maybe_nil_content_version(nil), do: %{ body: "Translation not found"}
  def maybe_nil_content_version(content_version), do: content_version

  @moduledoc """
  The render function takes a nested map of Docubits and renders it, and
  it's children recursively.
  """
  def render_editor(docubit = %UserDocs.Documents.DocuBit{children: []}, opts) do
    execute_render(docubit, opts, "")
  end
  def render_editor(docubit = %UserDocs.Documents.DocuBit{children: children}, opts) when is_list(children) do
    { content, _ } =
      Enum.reduce(docubit.children, { "", 0 },
        fn(c, { acc, id } ) ->
          { [ acc | render_editor(
            Map.put(c, :body_element_id, opts.prefix <> ":" <> Integer.to_string(id)),
            Map.put(opts, :prefix, opts.prefix <> ":" <> Integer.to_string(id))) ],
            id + 1
          }
        end
      )
    execute_render(docubit, opts, content)
  end

  def render(docubit = %UserDocs.Documents.DocuBit{children: []}, opts) do
    execute_render(docubit, opts, "")
  end
  def render(docubit = %UserDocs.Documents.DocuBit{children: children}, opts) when is_list(children) do
    content = Enum.reduce(docubit.children, "",
      fn(c, acc) -> acc <> render(c, opts)  end)
    execute_render(docubit, opts, content)
  end

  def execute_render(docubit, opts, content) do
    "Elixir.UserDocs.Documents.DocuBit.Renderers." <> opts.renderer
    |> String.to_existing_atom()
    |> apply(String.to_atom(docubit.type), [docubit, content])
  end


  def test_docubit_map do
    %{
      type: "row",
      data: %{},
      children: [
        %{
          type: "column",
          data: %{},
          children: [
            %{
              type: "text",
              data: %{ name: "name" },
              children: []
            }
          ]
        },
        %{
          type: "column",
          data: %{},
          children: [
            %{
              type: "text",
              data: %{ name: "name" },
              children: []
            }
          ]
        }
      ]
    }
  end

  def test_docubit_row do
    %{
      type: "row",
      data: %{},
      children: []
    }
  end
end

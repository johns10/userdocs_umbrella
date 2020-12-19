defmodule UserDocsWeb.DocubitLive.Renderers.P do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents.Content

  def render(assigns) do
    ~L"""
      <p>
        <%= display_content(assigns, @docubit) %>
        <%= @inner_content.([]) %>
      </p>
    """
  end

  def display_content(_, %Docubit{content: nil}) do
    "No Content has been loaded to this Docubit"
  end

  def display_content(assigns, %Docubit{content: %Content{} = content}) do
    IO.inspect(assigns.current_language_code_id)

    content.content_versions
    |> maybe_content_versions(assigns.current_version_id)
    |> maybe_language_code(assigns.current_language_code_id)
    |> maybe_body()
  end

  def maybe_content_versions(content_versions, version_id) do
    case Enum.filter(content_versions, fn cv -> cv.version_id == version_id end) do
      [] -> raise(RuntimeError, "Content Versions Not Found in maybe_content_versions")
      result -> result
    end
  end

  def maybe_language_code(content_versions, language_code_id) do
    case Enum.filter(content_versions, fn cv -> cv.language_code_id == language_code_id end) do
      [] -> raise(RuntimeError, "Content Versions Not Found in maybe_language_code")
      result -> result
    end
  end

  def maybe_body(content_versions) do
    case content_versions |> Enum.at(0) do
      nil -> raise(RuntimeError, "Content Version Not Found in maybe_body")
      result -> Map.get(result, :body)
    end
  end
end

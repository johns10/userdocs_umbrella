defmodule UserDocsWeb.DocubitLive.Renderers.Base do
  use Phoenix.LiveView
  use Phoenix.HTML
  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents.Content
  alias UserDocs.Documents.Docubit.Context
  alias UserDocsWeb.DocubitLive.Renderers.Base


  def render_inner_content(assigns) do
    ~L"""
      <%= if @component do %>
        <%= @inner_content.([]) %>
      <% else %>
        <%= for docubit <- @docubit.docubits do %>
          <%= Docubit.renderer(docubit).render(%{
            current_language_code_id: @current_language_code_id,
            current_version_id: @current_version_id,
            component: false,
            editor: false,
            docubit: docubit,
            content: Base.display_content(assigns, docubit),
            img_path: @img_path
          }) %>
        <% end %>
      <% end %>
    """
  end


  def maybe_content_header(
    header,
    %{ docubit: %Docubit{content: %Content{}} = docubit } = assigns
  ) do
    header
    |> List.insert_at(-1, display_content_header(assigns, docubit))
  end
  def maybe_content_header(header, %{ docubit: %Docubit{content: nil}}) do
    header
  end
  def maybe_content_name(header, _), do: header

  def display_content_header(assigns, %Docubit{content: %Content{ name: name, content_versions: []}}) do
    ": " <> name
  end
  def display_content_header(assigns, %Docubit{content: %Content{} = content}) do
    content.content_versions
    |> maybe_content_versions(assigns.current_version_id)
    |> maybe_language_code(assigns.current_language_code_id)
    |> maybe_header(to_string(content.name), assigns.current_version_id)
  end

  def display_content(assigns, %Docubit{content: %Content{ name: name, content_versions: []}}) do
    %{body: "No Content versions or translations have been added to the #{name} content.", prefix: nil, title: nil}
  end
  def display_content(_, %Docubit{content: nil}) do
    %{body: "No Content has been loaded to this Docubit", prefix: nil, title: nil}
  end
  def display_content(assigns, %Docubit{content: %Content{} = content} = docubit) do
    content.content_versions
    |> maybe_content_versions(assigns.current_version_id)
    |> maybe_language_code(assigns.current_language_code_id)
    |> maybe_body()
    |> maybe_name_prefix(docubit.context, content)
    |> maybe_title(docubit.context, content)
  end

  defp maybe_content_versions(content_versions, version_id) do
    case Enum.filter(content_versions, fn cv -> cv.version_id == version_id end) do
      [] -> highest_content_version(content_versions)
      result -> result
    end
  end

  defp highest_content_version(content_versions) do
    max_order =
      content_versions
      |> Enum.map(fn(cv) -> cv.version.order end)
      |> Enum.max()

    Enum.filter(content_versions, fn(cv) -> cv.version.order == max_order end)
  end

  defp maybe_language_code(content_versions, language_code_id) do
    case Enum.filter(content_versions, fn cv -> cv.language_code_id == language_code_id end) do
      [] -> raise(RuntimeError, "Content Versions Not Found in maybe_language_code")
      result -> result
    end
  end

  defp maybe_body(content_versions) do
    case content_versions |> Enum.at(0) do
      nil -> raise(RuntimeError, "Content Version Not Found in maybe_body")
      result -> %{ body: Map.get(result, :body) }
    end
  end

  defp maybe_name_prefix(current_content, %Context{ settings: %{ name_prefix: true } }, content) do
    Map.put(current_content, :prefix, content.title)
  end
  defp maybe_name_prefix(current_content, %Context{ settings: %{ name_prefix: false } }, _) do
    Map.put(current_content, :prefix, nil)
  end

  defp maybe_title(current_content, %Context{ settings: %{ show_title: true } }, content) do
    Map.put(current_content, :title, content.name)
  end
  defp maybe_title(current_content, %Context{ settings: %{ show_title: false } }, _) do
    Map.put(current_content, :title, nil)
  end
  defp maybe_title(current_content, _, _), do: Map.put(current_content, :title, nil)

  def maybe_render_title(%{title: nil}), do: ""
  def maybe_render_title(%{title: title}) do
    title
  end

  def maybe_render_prefix(%{prefix: nil}), do: content_tag(:strong, "", [])
  def maybe_render_prefix(%{prefix: prefix}) do
    content_tag(:strong, prefix <> " - ", [])
  end

  defp maybe_header(content_versions, content_name, current_version_id) do
    case content_versions |> Enum.at(0) do
      nil -> raise(RuntimeError, "Content Version Not Found in maybe_body")
      result ->
        ": "
        <> content_name
        <> " ("
        <> version_name(result, current_version_id)
        <> ")"
    end
  end

  defp version_name(content_version, current_version_id) do
    Map.get(content_version, :version)
    |> Map.get(:name)
    |> maybe_highlight_mismatch(content_version, current_version_id)
  end

  defp maybe_highlight_mismatch(content_version_name, content_version, current_version_id) do
    case content_version.version.id == current_version_id do
      true -> content_version_name
      false -> content_version_name <> "!"
    end
  end
end

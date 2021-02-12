defmodule UserDocsWeb.DocubitLive.Renderers.Img do
  use UserDocsWeb, :live_component
  use Phoenix.HTML
  alias UserDocsWeb.DocubitLive.Renderers.Base

  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents.Docubit.Context
  alias UserDocs.Documents.DocubitSetting, as: DocubitSettings

  def header(_), do: ""


  @impl true
  def render(%{ role: :html_export } = assigns) do
    ~L"""
    <img>
    <%= display_image(assigns, @docubit) %>
    """
  end

  def render(assigns) do
    ~L"""
      <img>
      <%= display_image(assigns, @docubit) %>
      <%= Base.render_inner_content(assigns) %>
    """
  end

  def display_image(assigns, docubit) do
    content_tag(:img, "", handle_opts(assigns, docubit))
  end

  def handle_opts(assigns, docubit) do
    []
    |> handle_src(assigns.img_path, docubit, assigns.role)
    |> handle_alt(docubit)
    |> handle_border(docubit)
  end

  def handle_src(opts, path, docubit, role) do
    { status, docubit } = maybe_file({ :ok, docubit })
    case status do
      :ok -> Keyword.put(opts, :src, maybe_path(path, role) <> docubit.file.filename)
      :nofile -> Keyword.put(opts, :src, path)
    end
  end

  def maybe_path(_path, :html_export), do: "images/"
  def maybe_path(path, _), do: path

  def handle_alt(opts, docubit) do
    { status, docubit } = maybe_file({ :ok, docubit })
    case status do
      :ok -> Keyword.put(opts, :alt, docubit.through_step.name)
      :nofile -> Keyword.put(opts, :alt, "No File Found for this Docubit")
    end
  end

  def maybe_file({ :ok, docubit = %Docubit{ file: nil }}) do
    { :nofile, docubit }
  end
  def maybe_file({ :ok, docubit = %Docubit{ file: _ }}) do
    { :ok, docubit }
  end

  def handle_border(opts,
    %Docubit{ context: %Context{ settings: settings = %DocubitSettings{
      img_border: true, border_color: border_color, border_width: border_width }}}
  ) do
    IO.puts("handle_border")
    opts
    |> Keyword.put(:border,
      "#{border_width}px solid #{border_color}")
  end
  def handle_border(opts, _), do: opts
end

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
    <%= display_image(assigns, @docubit) %>
    """
  end

  def render(assigns) do
    ~L"""
    <%= inspect(@docubit) %>
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
    { status, docubit } = maybe_screenshot({ :ok, docubit })
    IO.puts("handle_src")
    case status do
      :ok -> Keyword.put(opts, :src, docubit.screenshot.aws_file)
      :nofile -> Keyword.put(opts, :src, path)
    end
  end

  def maybe_path(_path, :html_export), do: "images/"
  def maybe_path(path, _), do: path

  def handle_alt(opts, docubit) do
    { status, docubit } = maybe_screenshot({ :ok, docubit })
    case status do
      :ok -> Keyword.put(opts, :alt, docubit.through_step.name)
      :nofile -> Keyword.put(opts, :alt, "No File Found for this Docubit")
    end
  end

  def maybe_screenshot({ :ok, docubit = %Docubit{ screenshot: nil }}) do
    { :nofile, docubit }
  end
  def maybe_screenshot({ :ok, docubit = %Docubit{ screenshot: _ }}) do
    { :ok, docubit }
  end

  def handle_border(opts,
    %Docubit{ context: %Context{ settings: %DocubitSettings{
      img_border: true, border_color: border_color, border_width: border_width }}}
  ) do
    IO.puts("handle_border")
    opts
    |> Keyword.put(:border,
      "#{border_width}px solid #{border_color}")
  end
  def handle_border(opts, _), do: opts
end

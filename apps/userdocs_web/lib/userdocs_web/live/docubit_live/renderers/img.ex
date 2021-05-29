defmodule UserDocsWeb.DocubitLive.Renderers.Img do
  use UserDocsWeb, :live_component
  use Phoenix.HTML
  alias UserDocsWeb.DocubitLive.Renderers.Base

  alias UserDocs.Media.Screenshot
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
      <%= display_image(assigns, @docubit) %>
      <%= Base.render_inner_content(assigns) %>
    """
  end

  def display_image(assigns, docubit) do
    IO.puts("Display image #{docubit.id}")
    content_tag(:img, "", handle_opts(assigns, docubit))
  end

  def handle_opts(assigns, docubit) do
    []
    |> handle_src(assigns.img_path, docubit, assigns.role)
    |> handle_alt(docubit)
    |> handle_border(docubit)
  end

  def handle_src(opts, path, %Docubit{ screenshot: nil }, role) do
    Keyword.put(opts, :src, path)
  end
  def handle_src(opts, path, %Docubit{ screenshot: %Screenshot{} = screenshot } = docubit, _role) do
    { status, url } = UserDocs.Media.get_screenshot_url(screenshot)
    fallback_path = ""
    case status do
      :ok -> Keyword.put(opts, :src, url)
      :nofile -> Keyword.put(opts, :src, fallback_path)
      :no_screenshot -> Keyword.put(opts, :src, fallback_path)
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

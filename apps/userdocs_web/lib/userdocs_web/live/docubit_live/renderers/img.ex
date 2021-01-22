defmodule UserDocsWeb.DocubitLive.Renderers.Img do
  use UserDocsWeb, :live_component
  use Phoenix.HTML
  alias UserDocsWeb.DocubitLive.Renderers.Base

  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents.Docubit.Context
  alias UserDocs.Documents.DocubitSetting, as: DocubitSettings

  def header(_), do: ""

  def render(assigns) do
    ~L"""
      <img>
      <%= display_image(assigns, @docubit) %>
      <%= Base.render_inner_content(assigns) %>
    """
  end

  def display_image(assigns, docubit) do
    IO.inspect(docubit)
    { status, docubit } =
      { :ok, docubit }
      |> maybe_file()

    content_tag(:img, "", handle_opts(assigns, docubit))
  end

  def handle_opts(assigns, docubit) do
    []
    |> handle_src(assigns.img_path, docubit)
    |> handle_alt(docubit)
    |> handle_border(docubit)
  end

  def handle_src(opts, path, docubit) do
    { status, docubit } = maybe_file({ :ok, docubit })
    case status do
      :ok -> Keyword.put(opts, :src, path <> docubit.file.filename)
      :nofile -> Keyword.put(opts, :src, path)
    end
  end

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

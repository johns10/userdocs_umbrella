defmodule UserDocsWeb.DocubitLive.Renderers.Img do
  use UserDocsWeb, :live_component
  use Phoenix.HTML
  alias UserDocsWeb.DocubitLive.Renderers.Base

  alias UserDocs.Documents.Docubit

  def header(_), do: ""

  def render(assigns) do
    ~L"""
      <img>
      <%= display_image(assigns, @docubit) %>
      <%= Base.render_inner_content(assigns) %>
    """
  end

  def display_image(assigns, docubit) do
    { status, docubit } =
      { :ok, docubit }
      |> maybe_file()

    case status do
      :ok -> content_tag(:img, "", [
          src: assigns.img_path <> docubit.file.filename
        ])
      :nofile -> content_tag(:img, "", [
        src: assigns.img_path,
        alt: " No File Found for this Docubit"
      ])
    end
  end

  def maybe_file({ :ok, docubit = %Docubit{ file: nil }}) do
    { :nofile, docubit }
  end
  def maybe_file({ :ok, docubit = %Docubit{ file: _ }}) do
    { :ok, docubit }
  end
end

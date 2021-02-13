defmodule UserDocsWeb.DocumentVersionDownloadController do
  use UserDocsWeb, :controller
  use UserDocsWeb, :live_view

  alias UserDocs.Documents.Docubit
  alias UserDocsWeb.DocumentLive.Viewer
  alias UserDocsWeb.DocubitLive.Renderers.Base

  def render(assigns) do
    ~L"""
    """
  end

  def show(conn, %{"id" => id}) do
    document_version = UserDocs.Documents.prepare_document_version(id)

    body =
      document_version.docubits |> Enum.at(0)
      |> Docubit.apply_context(%{ settings: %{} })
      |> Viewer.prepare_docubit(document_version.docubits)

    assigns = %{
      current_language_code_id: 1,
      current_version_id: document_version.version_id,
      component: false,
      editor: false,
      role: :html_export,
      img_path: Routes.static_path(conn, "/images/"),
      docubit: body
    }

    assigns =
      assigns
      |> Map.put(:content, Base.display_content(assigns, body))

    rendered =
      Docubit.renderer(body).render(assigns)

    result = Phoenix.HTML.Safe.to_iodata(rendered)

    tmp_folder_name = document_version.name
    target_path = File.cwd! <> "/tmp/" <> tmp_folder_name
    :ok = File.mkdir_p!(target_path)
    :ok = File.mkdir_p!(target_path <> "/images")

    document_version.docubits
    |> Enum.filter(fn(docubit) -> docubit.file_id != nil end)
    |> Enum.map(fn(docubit) -> docubit.file end)
    |> Enum.each(fn(file) ->
        source_file = File.cwd! <> "/apps/userdocs_web/assets/images/" <> file.filename
        File.copy(source_file, target_path <> "/images/" <> file.filename)
      end)

    File.write(target_path <> "/index.html", result)

    old_path = File.cwd!
    base_path = File.cwd! <> "/tmp/"
    File.cd!(base_path)
    :zip.create(
      tmp_folder_name <> ".zip",
      [ String.to_charlist(tmp_folder_name) ],
      [{:cwd, base_path}]
    )
    File.cd!(old_path)

    conn
    |> send_download({ :file, base_path <> tmp_folder_name <> ".zip" }, filename: tmp_folder_name <> ".zip")
  end

end

defmodule UserDocsWeb.DocumentVersionDownloadController do
  use UserDocsWeb, :controller

  alias UserDocs.Users
  alias UserDocs.Documents.Docubit
  alias UserDocsWeb.Root
  alias UserDocsWeb.DocumentLive.Viewer
  alias UserDocsWeb.DocubitLive.Renderers.Base

  def show(%{ assigns: %{ current_user: current_user }} = conn, %{"id" => id}) do
    IO.puts("Starting controller")
    document_version = UserDocs.Documents.prepare_document_version(id)

    current_user = Users.get_user_and_configs!(current_user.id)

    { default_team, _ } = Root.current_team(current_user)
    { default_project, _ } = Root.current_project(current_user, default_team)
    { _, current_version } = Root.current_version(current_user, default_project)

    body =
      document_version.docubits
      |> Enum.at(0)
      |> Docubit.apply_context(%{ settings: %{} })
      |> Viewer.prepare_docubit(document_version.docubits)

    assigns = %{
      current_language_code_id: 1,
      current_version: current_version,
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

    bucket =
      Application.get_env(:userdocs, :waffle)
      |> Keyword.get(:bucket)


    uploads_dir =
      Application.get_env(:userdocs, :userdocs_s3)
      |> Keyword.get(:uploads_dir)


    document_version.docubits
    |> Enum.filter(fn(docubit) -> docubit.screenshot_id != nil end)
    |> Enum.filter(fn(docubit) -> docubit.screenshot.aws_file != nil end)
    |> Enum.each(fn(d) ->
      path = uploads_dir <> "/" <> d.screenshot.aws_file.file_name
      local_path = File.cwd! <> "/tmp/" <> tmp_folder_name <> "/images/" <> d.screenshot.aws_file.file_name
      {:ok, :done} =
        ExAws.S3.download_file(bucket, path, local_path)
        |> ExAws.request
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

defmodule UserDocsWeb.ProcessLive.Loaders do

  alias UserDocs.Documents
  alias UserDocs.Automation
  alias UserDocs.Web
  alias UserDocs.Screenshots
  alias UserDocs.StepInstances

  def content(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{team_id: socket.assigns.current_team.id})
      |> Keyword.put(:params, %{})

    Documents.load_content(socket, opts)
  end

  def content_versions(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{team_id: socket.assigns.current_team.id})

    Documents.load_content_versions(socket, opts)
  end

  def processes(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{team_id: socket.assigns.current_team.id})

    Automation.load_processes(socket, opts)
  end

  def steps(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{version_id: socket.assigns.current_version.id})
      |> Keyword.put(:params, %{})

    Automation.load_steps(socket, opts)
  end

  def annotations(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{version_id: socket.assigns.current_version.id})
      |> Keyword.put(:params, %{})

    Web.load_annotations(socket, opts)
  end

  def elements(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{version_id: socket.assigns.current_version.id})
      |> Keyword.put(:params, %{})

    Web.load_elements(socket, opts)
  end

  def pages(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{version_id: socket.assigns.current_version.id})

    Web.load_pages(socket, opts)
  end

  def screenshots(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{version_id: socket.assigns.current_version.id})

    Screenshots.load_screenshots(socket, opts)
  end

  def step_instances(socket, opts) do
    opts = Keyword.put(opts, :params, %{ filters: %{version_id: socket.assigns.current_version.id } })
    StepInstances.load_step_instances(socket, opts)
  end

end

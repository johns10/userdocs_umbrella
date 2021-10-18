defmodule UserDocsWeb.ProcessLive.Loaders do

  alias UserDocs.Documents
  alias UserDocs.Annotations
  alias UserDocs.Automation
  alias UserDocs.Elements
  alias UserDocs.Web
  alias UserDocs.Screenshots
  alias UserDocs.StepInstances
  alias UserDocs.Projects

  def processes(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{team_id: socket.assigns.current_team.id})

    Automation.load_processes(socket, opts)
  end

  def steps(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{project_id: socket.assigns.current_project.id})
      |> Keyword.put(:params, %{})

    Automation.load_steps(socket, opts)
  end

  def annotations(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{project_id: socket.assigns.current_project.id})
      |> Keyword.put(:params, %{})

    Annotations.load_annotations(socket, opts)
  end

  def elements(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{project_id: socket.assigns.current_project.id})
      |> Keyword.put(:params, %{})

    Elements.load_elements(socket, opts)
  end

  def pages(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{project_id: socket.assigns.current_project.id})

    Web.load_pages(socket, opts)
  end

  def screenshots(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{project_id: socket.assigns.current_project.id})

    Screenshots.load_screenshots(socket, opts)
  end

  def step_instances(socket, opts) do
    opts = Keyword.put(opts, :filters, %{project_id: socket.assigns.current_project.id })
    StepInstances.load_project_step_instances(socket, opts)
  end

  def projects(socket, opts) do
    opts =
      opts
      |> Keyword.put(:filters, %{team_id: socket.assigns.current_team.id})

    Projects.load_projects(socket, opts)
  end

end

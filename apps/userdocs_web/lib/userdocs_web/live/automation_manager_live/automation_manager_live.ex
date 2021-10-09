defmodule UserDocsWeb.AutomationManagerLive do
  use UserDocsWeb, :live_slime_component

  alias UserDocs.Automation.Step
  alias UserDocs.AutomationManager
  alias UserDocs.Helpers
  alias UserDocs.Jobs
  alias UserDocs.Jobs.Job
  alias UserDocs.Jobs.JobProcess
  alias UserDocs.Jobs.JobStep
  alias UserDocs.ProcessInstances
  alias UserDocs.StepInstances
  alias UserDocs.Users


  require Logger

  def types, do: []

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:select_lists, %{jobs: []})
   }
  end

  @impl true
  def update(%{current_user: %{selected_team_id: team_id, job_id: nil}} = assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:job_id, nil)
      |> assign(:job, %Job{job_steps: [], job_processes: []})
      |> assign(:select_lists, %{jobs: jobs_select_list(team_id)})
    }
  end
  def update(%{current_user: %{selected_team_id: team_id, job_id: job_id}} = assigns, socket) do
    job = Jobs.get_job!(job_id, %{preloads: [steps: true, processes: true, last_job_instance: true]})
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:job_id, job_id)
      |> assign(:select_lists, %{jobs: jobs_select_list(team_id)})
      |> assign(:job, job)
    }
  end
  def update(%{event: "new-job-instance"} = assigns, socket) do
    job = Jobs.get_job!(socket.assigns.job.id, %{preloads: [steps: true, processes: true, last_job_instance: true]})
    {:ok, assign(socket, :job, job)}
  end
  def update(%{event: "update-step-instance", step_instance: step_instance} = assigns, socket) do
    job = UserDocs.Jobs.update_job_step_instance(socket.assigns.job, step_instance)
    {:ok, assign(socket, :job, job)}
  end
  def update(%{event: "update-process-instance", process_instance: process_instance} = assigns, socket) do
    job = UserDocs.Jobs.update_job_process(socket.assigns.job, process_instance)
    {:ok, assign(socket, :job, job)}
  end

  def render_job_item(object_instance, cid, interactive \\ true)
  def render_job_item(%JobStep{} = job_step, cid, interactive) do
    ~L"""
    li
      div.is-flex.is-flex-direction-row.is-flex-grow-0
        = UserDocsWeb.StepLive.Instance.status(job_step.step_instance)
        = link to: "#", phx_click: "delete-job-step", phx_value_id: job_step.id,phx_target: cid, class: "navbar-item py-0" do
          span.icon
            i.fa.fa-trash aria-hidden="true"
        = link to: "#", class: "py-0", style: "white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" do
          =< job_step.step.name
    """
  end
  def render_job_item(%JobProcess{} = job_process, cid, interactive) do
    ~L"""
    li
      input id="expand-job-process-<%= job_process.id %>" class="job-process-toggle" type="checkbox" hidden="true" checked=job_process.collapsed
      .is-flex-direction-column.py-0.job-process
        .is-flex.is-flex-direction-row.is-flex-grow-0.py-0
          = UserDocsWeb.ProcessLive.Instance.status(job_process.process_instance)
          = link to: "#", phx_click: "expand-job-process", phx_value_id: job_process.id, phx_target: cid, class: "navbar-item py-0" do
              span.icon
                i.fa.fa-angle-down.job-process-expanded aria-hidden="true"
          = link to: "#", phx_click: "delete-job-process", phx_value_job_process_id: job_process.id, phx_target: cid, class: "navbar-item py-0" do
            span.icon
              i.fa.fa-trash aria-hidden="true"
          = link to: "", class: "is-flex-grow-1 py-0" do
            =< job_process.process.name
        ul.my-0.job-process-steps id="job-process-<%= job_process.id %>-steps"
          = for step <- job_process.process.steps do
            = render_job_item(step, cid, false)
    """
  end
  def render_job_item(%Step{} = step, cid, interactive) do
    ~L"""
    li
      div.is-flex.is-flex-direction-row.is-flex-grow-0
        = UserDocsWeb.StepLive.Instance.status(step.last_step_instance)
        = if interactive do
          = link to: "#", phx_click: "remove-step-instance", phx_value_d: step.id,phx_target: cid, class: "navbar-item py-0" do
            span.icon
              i.fa.fa-plus aria-hidden="true"
        = link to: "#", class: "py-0", style: "white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" do
          =< step.name
    """
  end

  def render_instance_status(status) do
    case status do
      "not_started" -> content_tag(:i, "", [class: "fa fa-play-circle", aria_hidden: "true"])
      "failed" -> content_tag(:i, "", [class: "fa fa-times", aria_hidden: "true"])
      "started" -> content_tag(:i, "", [class: "fa fa-spinner", aria_hidden: "true"])
      "complete" -> content_tag(:i, "", [class: "fa fa-check", aria_hidden: "true"])
    end
  end

  @impl true
  def handle_event("job-changed", %{"job" => %{"job_id" => ""}}, socket), do: {:noreply, socket}
  def handle_event("job-changed", %{"job" => %{"job_id" => job_id}}, socket) do
    job = Jobs.get_job!(job_id, %{preloads: [steps: true, processes: true, last_job_instance: true]})
    {:ok, user} = Users.update_user_selections(socket.assigns.current_user, %{job_id: job.id})
    send(self(), {:broadcast, "update", user})
    {
      :noreply,
      socket
      |> assign(:job, job)
      |> assign(:job_id, job.id)
    }
  end
  def handle_event("expand-job-process", %{"id" => id}, socket) do
    {:ok, job} = Jobs.expand_job_process(socket.assigns.job, id |> String.to_integer())
    {:noreply, assign(socket, :job, job)}
  end
  def handle_event("create-job-step", %{"step-id" => step_id}, socket) do
    job = socket.assigns.job
    case Jobs.create_job_step(job, String.to_integer(step_id)) do
      {:ok, _job_step} -> {:noreply, job |> assign_job(socket)}
      {:error, changeset} ->
        formatted_errors = format_changeset_errors(changeset)
        {:noreply, Phoenix.LiveView.put_flash(socket, :error,  formatted_errors)}
    end
  end
  def handle_event("delete-job-step", %{"id" => job_step_id}, socket) do
    case Jobs.delete_job_step(%JobStep{id: String.to_integer(job_step_id)}) do
      {:ok, _job_step} -> {:noreply, socket.assigns.job |> assign_job(socket)}
      {:error, _changeset} ->
        {:noreply, Phoenix.LiveView.put_flash(socket, :error, "Failed to remove process from job")}
    end
  end
  def handle_event("create-job-process", %{"id" => process_id, "name" => process_name}, socket) do
    job = socket.assigns.job
    case Jobs.create_job_process(job, String.to_integer(process_id)) do
      {:ok, _job_process} -> {:noreply, job |> assign_job(socket)}
      {:error, changeset} ->
        formatted_errors = format_changeset_errors(changeset)
        {:noreply, Phoenix.LiveView.put_flash(socket, :error,  formatted_errors)}
    end
  end
  def handle_event("delete-job-process", %{"job-process-id" => job_process_id}, socket) do
    case Jobs.delete_job_process(%JobProcess{id: String.to_integer(job_process_id)}) do
      {:ok, job_process} -> {:noreply, socket.assigns.job |> assign_job(socket)}
      {:error, changeset} ->
        {:noreply, Phoenix.LiveView.put_flash(socket, :error, "Failed to remove process from job")}
    end
  end
  def handle_event("execute-job", %{"id" => job_id}, socket) do
    user_id = socket.assigns.current_user.id |> to_string
    UserDocsWeb.Endpoint.broadcast("user:" <> user_id, "command:execute_job", %{job_id: job_id})
    {:noreply, socket}
  end
  def handle_event("execute-step", %{"id" => step_id}, socket) do
    user_id = socket.assigns.current_user.id |> to_string
    UserDocsWeb.Endpoint.broadcast("user:" <> user_id, "command:execute_step", %{step_id: step_id})
    {:noreply, socket}
  end
  def handle_event("execute-process", %{"id" => process_id}, socket) do
    user_id = socket.assigns.current_user.id |> to_string
    UserDocsWeb.Endpoint.broadcast("user:" <> user_id, "command:execute_process", %{process_id: process_id})
    {:noreply, socket}
  end

  def assign_job(%Jobs.Job{id: id}, socket) do
    job = Jobs.get_job!(id, %{preloads: [steps: true, processes: true, last_job_instance: true]})
    assign(socket, :job, job)
  end

  def jobs_select_list(team_id) do
    Jobs.list_jobs(%{filters: [team_id: team_id]})
    |> Helpers.select_list(:name, true)
  end

  def format_changeset_errors(changeset) do
    errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)

    errors
    |> Enum.map(&format_errors/1)
    |> Enum.join("\n")
  end

  def format_errors(error) when is_binary(error), do: error
  def format_errors(%{} = errors), do: Enum.map(errors, &format_errors/1)
  def format_errors([_ | _] = errors), do: Enum.map(errors, &format_errors/1)
  def format_errors({key, value}), do: "#{key}: #{format_errors(value)}"
end

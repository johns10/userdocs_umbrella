defmodule UserDocsWeb.AutomationManagerLive do
  use UserDocsWeb, :live_slime_component

  alias UserDocs.Jobs
  alias UserDocs.Jobs.JobStep
  alias UserDocs.Jobs.JobProcess
  alias UserDocs.Automation.Step
  alias UserDocs.AutomationManager
  alias UserDocs.StepInstances

  alias UserDocs.StepInstances.StepInstance
  alias UserDocs.ProcessInstances.ProcessInstance

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
    }
  end

  @impl true
  def update(assigns, socket) do
    if (assigns.job_id) do
      job = Jobs.get_job!(assigns.job_id, %{ preloads: [ steps: true, processes: true ]})
      {
        :ok,
        socket
        |> assign(assigns)
        |> assign(:job, job)
      }
    else
      { :ok, assign(socket, assigns) }
    end
  end

  def render_job_item(object_instance, cid, interactive \\ true)
  def render_job_item(%JobStep{} = job_step, cid, interactive) do
    ~L"""
    li
      div.is-flex.is-flex-direction-row.is-flex-grow-0
        = link to: "#", phx_click: "delete-job-step", phx_value_id: job_step.id,phx_target: cid, class: "navbar-item py-0" do
          span.icon
            i.fa.fa-trash aria-hidden="true"
        = link to: "#", class: "py-0", style: "white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" do
          =< to_string(job_step.order)
          | :
          =< job_step.step.name
          | (
          = job_step.step.id
          | )
    """
  end
  def render_job_item(%JobProcess{} = job_process, cid, interactive) do
    ~L"""
    li
      input id="expand-job-process-<%= job_process.id %>" class="job-process-toggle" type="checkbox" hidden="true" checked=job_process.collapsed
      .is-flex-direction-column.py-0.job-process
        .is-flex.is-flex-direction-row.is-flex-grow-0.py-0
          = link to: "#", phx_click: "expand-job-process", phx_value_id: job_process.id, phx_target: cid, class: "navbar-item py-0" do
              span.icon
                i.fa.fa-angle-down.job-process-expanded aria-hidden="true"
          = link to: "#", phx_click: "delete-job-process", phx_value_job_process_id: job_process.id, phx_target: cid, class: "navbar-item py-0" do
            span.icon
              i.fa.fa-trash aria-hidden="true"
          = link to: "", class: "is-flex-grow-1 py-0" do
            = job_process.order || ""
            | :
            =< job_process.id
        ul.my-0.job-process-steps id="job-process-<%= job_process.id %>-steps"
          = for step <- job_process.process.steps do
            = render_job_item(step, cid, false)
    """
  end
  def render_job_item(%Step{} = step, cid, interactive) do
    ~L"""
    li
      div.is-flex.is-flex-direction-row.is-flex-grow-0
        = if interactive do
          = link to: "#", phx_click: "remove-step-instance", phx_value_d: step.id,phx_target: cid, class: "navbar-item py-0" do
            span.icon
              i.fa.fa-plus aria-hidden="true"
        = link to: "#", class: "py-0", style: "white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" do
          =< to_string(step.order)
          | :
          =< step.name
          | (
          = step.id
          | )
    """
  end
  # Deprecated
  def render_job_item(%ProcessInstance{} = process_instance, cid, interactive) do
    ~L"""
    li
      .is-flex.py-0
        .is-flex.is-flex-direction-row.is-flex-grow-0.py-0
          = link to: "#", phx_click: "remove-process-instance", phx_value_process_instance_id: process_instance.id, phx_target: cid, class: "navbar-item py-0" do
            span.icon
              i.fa.fa-trash aria-hidden="true"
          = link to: "#", phx_click: "expand-process-instance", phx_value_id: process_instance.id, phx_target: cid, class: "navbar-item py-0" do
            span.icon
              = if process_instance.expanded do
                i.fa.fa-minus aria-hidden="true"
              - else
                i.fa.fa-plus aria-hidden="true"
          = link to: "#", class: "py-0" do
            = render_instance_status(process_instance.status)
        = link to: "", class: "is-flex-grow-1 py-0" do
          = process_instance.order || ""
          | :
          =< process_instance.name
      = if process_instance.expanded do
        ul.my-0
          = for step_instance <- process_instance.step_instances do
            = render_job_item(step_instance, cid, false)
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
  def handle_event("reset-job", _payload, socket) do
    { :ok, updated_job } = Jobs.reset_job_status(socket.assigns.job)
    { :noreply, assign(socket, :job, updated_job) }
  end
  def handle_event("put-job", _payload, socket) do
    { :noreply, push_event(socket, "put-job", %{ data: Jobs.export_job(socket.assigns.job) }) }
  end
  def handle_event("start-running", _payload, socket) do
    { :noreply, push_event(socket, "start-running", %{}) }
  end
  def handle_event("expand-job-process", %{ "id" => id }, socket) do
    { :ok, job } = Jobs.expand_job_process(socket.assigns.job, id |> String.to_integer())
    { :noreply, assign(socket, :job, job) }
  end
  def handle_event("create-job-step", %{ "step-id" => step_id }, socket) do
    job = socket.assigns.job
    case Jobs.create_job_step(job, String.to_integer(step_id)) do
      { :ok, job_step } -> { :noreply, job |> put_job(socket) }
      { :error, changeset } ->
        formatted_errors = format_changeset_errors(changeset)
        { :noreply, Phoenix.LiveView.put_flash(socket, :error,  formatted_errors) }
    end
  end
  def handle_event("delete-job-step", %{ "id" => job_step_id }, socket) do
    case Jobs.delete_job_step(%JobStep{ id: String.to_integer(job_step_id) }) do
      { :ok, job_step } -> { :noreply, socket.assigns.job |> put_job(socket) }
      { :error, changeset } ->
        { :noreply, Phoenix.LiveView.put_flash(socket, :error, "Failed to remove process from job") }
    end
  end
  """
  Deprecated
  def handle_event("add-step-instance", %{ "step-id" => step_id }, socket) do
    case Jobs.add_step_instance_to_job(socket.assigns.job, String.to_integer(step_id)) do
      { :ok, job } -> { :noreply, socket |> assign(:job, job) }
      { :error, changeset } ->
        formatted_errors = format_changeset_errors(changeset)
        { :noreply, Phoenix.LiveView.put_flash(socket, :error,  formatted_errors) }
    end
  end
  def handle_event("remove-step-instance", %{ "step-instance-id" => id }, socket) do
    case Jobs.remove_step_instance_from_job(socket.assigns.job, String.to_integer(id)) do
      { :ok, job } ->
        { :noreply, socket |> assign(:job, job) }
      { :error, changeset } ->
        { :noreply, Phoenix.LiveView.put_flash(socket, :error, "Failed to remove step instance") }
    end
  end
  """
  def handle_event("create-job-process", %{ "process-id" => process_id }, socket) do
    job = socket.assigns.job
    case Jobs.create_job_process(job, String.to_integer(process_id)) do
      { :ok, job_process } -> { :noreply, job |> put_job(socket) }
      { :error, changeset } ->
        formatted_errors = format_changeset_errors(changeset)
        { :noreply, Phoenix.LiveView.put_flash(socket, :error,  formatted_errors) }
    end
  end
  def handle_event("delete-job-process", %{ "job-process-id" => job_process_id }, socket) do
    case Jobs.delete_job_process(%JobProcess{ id: String.to_integer(job_process_id) }) do
      { :ok, job_process } -> { :noreply, socket.assigns.job |> put_job(socket) }
      { :error, changeset } ->
        { :noreply, Phoenix.LiveView.put_flash(socket, :error, "Failed to remove process from job") }
    end
  end
  """
  def handle_event("add-process-instance", %{ "process-id" => process_id }, socket) do
    case Jobs.add_process_instance_to_job(socket.assigns.job, String.to_integer(process_id)) do
      { :ok, job } -> { :noreply, socket |> assign(:job, Jobs.get_job!(job.id, %{ preloads: "*"})) }
      { :error, changeset } ->
        formatted_errors = format_changeset_errors(changeset)
        { :noreply, Phoenix.LiveView.put_flash(socket, :error,  formatted_errors) }
    end
  end
  def handle_event("remove-process-instance", %{ "process-instance-id" => process_instance_id }, socket) do
    case Jobs.remove_process_instance_from_job(socket.assigns.job, String.to_integer(process_instance_id)) do
      { :ok, job } ->
        { :noreply, socket |> assign(:job, job) }
      { :error, changeset } ->
        { :noreply, Phoenix.LiveView.put_flash(socket, :error, "Failed to remove step instance") }
    end
  end
  """
  def handle_event("update-step-instance", %{ "id" => _id, "status" => _status, "errors" => _errors } = payload, socket) do
    { :ok, job } = Jobs.update_job_step_instance(socket.assigns.job, payload)
    socket = maybe_update_step(socket, payload)
    { :noreply, assign(socket, :job, job) }
  end
  def handle_event("create-job", %{ "team-id" => team_id } = payload, socket) do
    IO.puts("Create job for #{team_id}")
    { :ok, job } = UserDocs.Jobs.create_job(%{ team_id: team_id })
    { :noreply, assign(socket, :job, job) }
  end
  def handle_event("execute_step", %{ "id" => step_id } = payload, socket) do
    step =
      AutomationManager.get_step!(step_id)
      |> UserDocs.Automation.Runner.parse()
    {
      :noreply,
      socket
      |> Phoenix.LiveView.push_event("execute", %{ step: step })
    }
  end

  def put_job(%Jobs.Job{ id: id }, socket) do
    job = Jobs.get_job!(id, %{ preloads: [ processes: true, steps: true ]})
    assign(socket, :job, job)
  end

  def maybe_update_step(socket, %{ "status" => status, "step_id" => step_id, "attrs" => attrs })
  when status == "complete" do
    # { :ok, _step } = update_step_status(step_id, status)
    case attrs["screenshot"] do
      nil -> socket
      %{ "id" => id, "base_64" => _ } = attrs ->
        { :ok, screenshot } = UserDocs.Screenshots.get_screenshot!(id)
        |> UserDocs.Screenshots.update_screenshot(attrs, socket.assigns.team)
        send(self(), { :broadcast, "update", screenshot })
        socket
      %{ "base_64" => _ } = attrs ->
        { :ok, screenshot } = UserDocs.Screenshots.create_screenshot(%{ step_id: step_id })
        { :ok, screenshot } = UserDocs.Screenshots.update_screenshot(screenshot, attrs, socket.assigns.team)
        send(self(), { :broadcast, "update", screenshot })
        socket
    end
  end
  def maybe_update_step(socket, %{ "status" => status, "step_id" => step_id }) when status == "failed" do
    #update_step_status(step_id, status)
    socket
  end
  def maybe_update_step(socket, _attrs), do: socket

  """
  def update_step_status(step_id, status) do
    UserDocs.Automation.get_step!(step_id)
    |> UserDocs.Automation.update_step_status(%{ status: status })
  end
  """

  def maybe_update_screenshot(%{ "id" => id, "base_64" => _ } = attrs, team) do
    IO.inspect("updating sscreenshot")
    UserDocs.Screenshots.get_screenshot!(id)
    |> UserDocs.Screenshots.update_screenshot(attrs, team)
  end
  def maybe_update_screenshot(%{ "base_64" => _ } = attrs, team) do
    IO.inspect("creating sscreenshot")
    { :ok, screenshot } = UserDocs.Screenshots.create_screenshot(attrs)
    UserDocs.Screenshots.update_screenshot(screenshot, attrs, team)
  end
  def maybe_update_screenshot(attrs, _team), do: { :ok, attrs }

  """
  def execute_step(socket, %{ step_id: step_id }) do
    with step = AutomationManager.get_step!(step_id),
      { :ok, step_instance } = StepInstances.create_step_instance_from_step(step),
      preloaded_step_instance = Map.put(step_instance, :step, step),
      formatted_step_instance = StepInstances.format_step_instance_for_export(preloaded_step_instance)
    do
      socket
      |> Phoenix.LiveView.push_event("execute", %{ step_instance: formatted_step_instance })
    else
      _ -> raise("Execute Step Failed in #{__MODULE__}")
    end
  end
  """

  def execute_process_instance(socket, %{ process_id: process_id }, order) do
    socket
    |> UserDocsWeb.ElectronWebDriver.ProcessInstance.execute(process_id, order)
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
  def format_errors([ _ | _ ] = errors), do: Enum.map(errors, &format_errors/1)
  def format_errors({ key, value }), do: "#{key}: #{format_errors(value)}"
end

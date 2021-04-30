defmodule UserDocsWeb.AutomationManagerLive do
  use UserDocsWeb, :live_slime_component

  alias UserDocs.Jobs
  alias UserDocs.AutomationManager
  alias UserDocs.StepInstances

  alias UserDocs.StepInstances.StepInstance
  alias UserDocs.ProcessInstances.ProcessInstance

  @topic "automation_manager"

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
    }
  end

  @impl true
  def update(assigns, socket) do
    UserDocsWeb.Endpoint.subscribe(@topic)
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  def render_job_item(object_instance, cid, interactive \\ true)
  def render_job_item(%StepInstance{} = step_instance, cid, interactive) do
    ~L"""
    li
      div.is-flex.is-flex-direction-row.is-flex-grow-0
        = if interactive do
          = link to: "#", phx_click: "remove-step-instance", phx_value_step_instance_id: step_instance.id,phx_target: cid, class: "navbar-item py-0" do
            span.icon
              i.fa.fa-trash aria-hidden="true"
        = link to: "#", class: "py-0" do
          = render_instance_status(step_instance.status)
        = link to: "#", class: "py-0", style: "white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" do
          =< to_string(step_instance.order)
          | :
          =< step_instance.name
    """
  end
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
  def handle_event("expand-process-instance", %{ "id" => id }, socket) do
    { :ok, job } = Jobs.expand_process_instance(socket.assigns.job, id |> String.to_integer())
    { :noreply, assign(socket, :job, job) }
  end
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

  def maybe_update_step(socket, %{ "status" => status, "step_id" => step_id, "attrs" => attrs })
  when status == "complete" do
    { :ok, _screenshot } = maybe_update_screenshot(attrs["screenshot"], socket.assigns.team)
    # { :ok, _step } = update_step_status(step_id, status)
    socket
  end
  def maybe_update_step(socket, %{ "status" => status, "step_id" => step_id }) when status == "failed" do
    update_step_status(step_id, status)
    socket
  end
  def maybe_update_step(socket, _attrs), do: socket

  def update_step_status(step_id, status) do
    UserDocs.Automation.get_step!(step_id)
    |> UserDocs.Automation.update_step_status(%{ status: status })
  end

  def maybe_update_screenshot(%{ "id" => id, "base_64" => _ } = attrs, team) do
    IO.puts("Got a base64 string")
    UserDocs.Screenshots.get_screenshot!(id)
    |> UserDocs.Screenshots.update_screenshot(attrs, team)
  end
  def maybe_update_screenshot(attrs, _team), do: { :ok, attrs }

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

defmodule UserDocsWeb.AutomationManagerLive do
  use UserDocsWeb, :live_component

  alias UserDocs.Jobs
  alias UserDocs.AutomationManager
  alias UserDocs.Jobs.Job
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

  def render_job_item(%StepInstance{} = step_instance, cid) do
    content_tag(:li, []) do
      content_tag(:div, [ class: "is-flex is-flex-direction-row is-flex-grow-0" ]) do
        [
          link([ to: "#", phx_click: "remove-step-instance",
            phx_value_step_instance_id: step_instance.id,
            phx_target: cid,
            class: "navbar-item py-0"
          ]) do
            content_tag(:span, [ class: "icon" ]) do
              content_tag(:i, "", [class: "fa fa-trash", aria_hidden: "true"])
            end
          end,
          link([ to: "#", class: "py-0" ]) do
            [ step_instance.status, ", ", to_string(step_instance.order), ": ", step_instance.name ]
          end
        ]
      end
    end
  end

  def render_job_item(%ProcessInstance{} = process_instance, cid) do
    ~L"""
    li
      .is-flex.py-0
        .is-flex.is-flex-direction-row.is-flex-grow-0.py-0
          = link to: "#", phx_click: "remove-process-instance", phx_value_process_instance_id: process_instance.id, phx_target: cid, class: "navbar-item py-0" do
            span.icon
              i.fa.fa-trash aria-hidden="true"
          = link to: "#", phx_click: "expand-process-instance", phx_value_id: process_instance.id, phx_target: cid, class: "navbar-item py-0" do
            span.icon
              i.fa.fa-plus aria-hidden="true"
        = link to: "", class: "is-flex-grow-1 py-0" do
          = process_instance.order
          | :
          =< process_instance.name
        = if process_instance.expanded do
          ul.my-0
            = for step_instance <- process_instance.step_instances do
              = render_job_item(step_instance, cid)
        - else
          = inspect(process_instance.expanded)
    """
  end

  @impl true
  def handle_event("put-job", %{ "app-name" => "electron" }, socket) do
    IO.inspect("Put job event")
    {
      :noreply,
      socket
      |> push_event("put-job", %{ data: Jobs.export_job(socket.assigns.job) })
    }
  end
  def handle_event("start-running", %{ "app-name" => "electron" }, socket) do
    {
      :noreply,
      socket
      |> push_event("start-running", %{})
    }
  end
  def handle_event("expand-process-instance", %{ "id" => id }, socket) do
    { :ok, job } = Jobs.expand_process_instance(socket.assigns.job, id)

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
        IO.inspect(job.step_instances)
        { :noreply, socket |> assign(:job, job) }
      { :error, changeset } ->
        { :noreply, Phoenix.LiveView.put_flash(socket, :error, "Failed to remove step instance") }
    end
  end
  def handle_event("add-process-instance", %{ "process-id" => process_id }, socket) do
    case Jobs.add_process_instance_to_job(socket.assigns.job, String.to_integer(process_id)) do
      { :ok, job } -> { :noreply, socket |> assign(:job, job) }
      { :error, changeset } ->
        formatted_errors = format_changeset_errors(changeset)
        { :noreply, Phoenix.LiveView.put_flash(socket, :error,  formatted_errors) }
    end
  end
  def handle_event("remove-process-instance", %{ "process-instance-id" => process_instance_id }, socket) do
    case Jobs.remove_process_instance_from_job(socket.assigns.job, String.to_integer(process_instance_id)) do
      { :ok, job } ->
        IO.inspect(job.step_instances)
        { :noreply, socket |> assign(:job, job) }
      { :error, changeset } ->
        { :noreply, Phoenix.LiveView.put_flash(socket, :error, "Failed to remove step instance") }
    end
  end
  def handle_event("update-step-instance", %{ "step-instance-id" => id, "status" => status, "errors" => errors } = payload, socket) do
    IO.inspect("update-step-instance")
    { :ok, job } = Jobs.update_job_step_instance(socket.assigns.job, payload)
    {
      :noreply,
      socket
      |> assign(:job, job)
    }
  end

  def execute_step(socket, %{ step_id: step_id }) do
    socket
    |> UserDocsWeb.ElectronWebDriver.StepInstance.execute(step_id)
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

defmodule UserDocsWeb.AutomationManagerLive do
  use UserDocsWeb, :live_component

  alias UserDocs.Jobs
  alias UserDocs.AutomationManager
  alias UserDocs.Jobs.Job
  alias UserDocs.Jobs.StepInstance
  alias UserDocs.Jobs.ProcessInstance

  @topic "automation_manager"

  @impl true
  def mount(socket) do
    { :ok, job } = Jobs.create_job()
    {
      :ok,
      socket
      |> assign(:job, job)
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
      link([ to: "#", class: "py-0" ]) do
        [ to_string(step_instance.order), ": ", step_instance.name ]
      end
    end
  end

  def render_job_item(%ProcessInstance{} = process_instance, cid) do
    [
      content_tag(:li, []) do
        [
          content_tag(:div, [ class: "is-flex py-0" ]) do
            [
              content_tag(:div, [ class: "is-flex is-flex-direction-row is-flex-grow-0 py-0" ]) do
                link([ to: "#", phx_click: "expand-process-instance", phx_value_id: process_instance.id, phx_target: cid, class: "navbar-item py-0" ]) do
                  content_tag(:span, [ class: "icon" ]) do
                    content_tag(:i, "", [class: "fa fa-plus", aria_hidden: "true"])
                  end
                end
              end,
              link(to: "", class: "is-flex-grow-1 py-0") do
                [ to_string(process_instance.order), ": ", process_instance.name ]
              end
            ]
          end,
          if process_instance.expanded do
            content_tag(:ul, [ class: "my-0"]) do
              for step_instance <- process_instance.step_instances do
                render_job_item(step_instance, cid)
              end
            end
          else
            ""
          end
        ]
      end
    ]
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
  def handle_event("add_step", %{ "app" => "electron", "step-id" => step_id }, socket) do
    { :ok, step_instance } =
      AutomationManager.get_step!(String.to_integer(step_id))
      |> Jobs.create_step_instance_from_step(Jobs.max_order(socket.assigns.job) + 1)

    case Jobs.add_item_to_job_queue(socket.assigns.job, step_instance) do
      { :ok, job } -> { :noreply, socket |> assign(:job, job) }
      { :error, changeset } ->
        {
          :noreply,
          socket
          |> Phoenix.LiveView.put_flash(:error, format_changeset_errors(changeset))
        }
    end
  end
  def handle_event("queue_process_instance", %{"app" => "electron", "process-id" => id }, socket) do
    IO.puts("queue_process_instance")
    IO.inspect(Jobs.max_order(socket.assigns.job))
    AutomationManager.get_process!(id)
    |> Jobs.create_process_instance_from_process(Jobs.max_order(socket.assigns.job) + 1)
    |> case do
      { :ok, process_instance } ->
        case Jobs.add_item_to_job_queue(socket.assigns.job, process_instance) do
          { :ok, job } -> { :noreply, socket |> assign(:job, job) }
          { :error, changeset } ->
            {
              :noreply,
              put_flash(socket, :error, format_changeset_errors(changeset))
            }
        end

      { :error, changeset } ->
        {
          :noreply,
          put_flash(socket, :error, format_changeset_errors(changeset))
        }
    end
  end

  def execute_step(socket, %{ step_id: step_id }) do
    socket
    |> UserDocsWeb.ElectronWebDriver.StepInstance.execute(step_id)
  end

  def execute_process_instance(socket, %{ process_id: process_id }, order) do
    socket
    |> UserDocsWeb.ElectronWebDriver.ProcessInstance.execute(process_id, order)
  end

  def handle_event("update-step", %{ "id" => id, "status" => status, "errors" => errors }, socket) do
    job =
      Enum.map(socket.assigns.job,
        fn(si) ->
          case si.id == id do
            true ->
              attrs = %{
                errors: errors,
                status: status
              }
              { :ok, step_instance } =
                Jobs.update_step_instance(si, attrs)
              step_instance
            false -> si
          end
        end
      )
    {
      :noreply,
      socket
      |> assign(:job, job)
    }
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

defmodule UserDocsWeb.AutomationManagerLive do
  use UserDocsWeb, :live_slime_component

  alias UserDocs.Automation
  alias UserDocs.Automation.Process
  alias UserDocs.Automation.Runner
  alias UserDocs.Automation.Step
  alias UserDocs.AutomationManager
  alias UserDocs.Jobs
  alias UserDocs.Jobs.JobProcess
  alias UserDocs.Jobs.JobStep
  alias UserDocs.StepInstances

  alias UserDocs.ProcessInstances
  alias UserDocs.ProcessInstances.ProcessInstance
  alias UserDocs.StepInstances.StepInstance

  require Logger

  def types, do: []

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
   }
  end

  @impl true
  def update(assigns, socket) do

    if assigns.job_id do
      job =
        assigns.job_id
        |> Jobs.get_job!(%{preloads: [steps: true, processes: true, last_job_instance: true]})
        |> Jobs.prepare_for_execution()

      {
        :ok,
        socket
        |> assign(assigns)
        |> assign(:job, job)
     }
    else
      {:ok, assign(socket, assigns)}
    end
  end

  def inspect_job(%Jobs.Job{} = job, prefix \\ "") do
    IO.puts("id: #{job.id}, status: #{job.status}, job_processes: ")
    Enum.each(job.job_processes, fn(jp) -> inspect_job_process(jp, "  ") end)
    job
  end

  def inspect_job_process(%UserDocs.Jobs.JobProcess{} = job_process, prefix \\ "") do
    IO.puts(prefix <> "id: #{job_process.id}, process_id: #{job_process.process_id}, process: ")
    if job_process.process, do: inspect_process(job_process.process, prefix <> "  ")
    IO.puts(prefix <> "process_instance_id: #{job_process.process_instance_id}, process_instance: ")
  end

  def inspect_process(%UserDocs.Automation.Process{} = process, prefix \\ "") do
    IO.puts(prefix <> "id: #{process.id}, order: #{process.order}, name: #{process.name}, steps: ")
    Enum.each(process.steps, fn(s) -> inspect_step(s, prefix <> "  ") end)
  end

  def inspect_step(%UserDocs.Automation.Step{} = step, prefix \\ "") do
    IO.puts(prefix <> "id: #{step.id}, order: #{step.order}, name: #{step.name}, last_step_instance: ")
    inspect_step_instance(step.last_step_instance, prefix <> "  ")
  end

  def inspect_step_instance(%Ecto.Association.NotLoaded{} = step_instance, prefix), do: IO.puts(prefix <> "Not Loaded")
  def inspect_step_instance(%UserDocs.StepInstances.StepInstance{} = step_instance, prefix \\ "") do
    IO.puts(prefix <> "id: #{step_instance.id}, order: #{step_instance.order}, name: #{step_instance.name}")
  end

  def render_job_item(object_instance, cid, interactive \\ true)
  def render_job_item(%JobStep{} = job_step, cid, interactive) do
    ~L"""
    li
      div.is-flex.is-flex-direction-row.is-flex-grow-0
        = UserDocsWeb.StepLive.Instance.status(job_step.step.last_step_instance)
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
          = UserDocsWeb.ProcessLive.Instance.status(job_process.process_instance)
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
        = UserDocsWeb.StepLive.Instance.status(step.last_step_instance)
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
    {:ok, job_instance} = UserDocs.JobInstances.create_job_instance(socket.assigns.job)

    {:noreply, assign_job(socket.assigns.job, socket)}
  end
  def handle_event("start-running", _payload, socket) do
    {:noreply, push_event(socket, "start-running", %{})}
  end
  def handle_event("expand-job-process", %{"id" => id}, socket) do
    {:ok, job} = Jobs.expand_job_process(socket.assigns.job, id |> String.to_integer())
    {:noreply, assign(socket, :job, job)}
  end
  def handle_event("create-job-step", %{"step-id" => step_id}, socket) do
    job = socket.assigns.job

    {:ok, step_instance} =
      AutomationManager.get_step!(step_id)
      |> StepInstances.create_step_instance_from_step(Jobs.max_order(job) + 1)

    case Jobs.create_job_step(job, String.to_integer(step_id), step_instance.id) do
      {:ok, job_step} -> {:noreply, job |> assign_job(socket)}
      {:error, changeset} ->
        formatted_errors = format_changeset_errors(changeset)
        {:noreply, Phoenix.LiveView.put_flash(socket, :error,  formatted_errors)}
    end
  end
  def handle_event("delete-job-step", %{"id" => job_step_id}, socket) do
    case Jobs.delete_job_step(%JobStep{id: String.to_integer(job_step_id)}) do
      {:ok, job_step} -> {:noreply, socket.assigns.job |> assign_job(socket)}
      {:error, changeset} ->
        {:noreply, Phoenix.LiveView.put_flash(socket, :error, "Failed to remove process from job")}
    end
  end
  def handle_event("create-job-process", %{"id" => process_id, "name" => process_name}, socket) do
    job = socket.assigns.job

    {:ok, process_instance} =
      AutomationManager.get_process!(process_id)
      |> ProcessInstances.create_process_instance_from_process(Jobs.max_order(job) + 1)

    case Jobs.create_job_process(job, String.to_integer(process_id), process_instance.id) do
      {:ok, job_process} -> {:noreply, job |> assign_job(socket)}
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
  def handle_event("delete-job", %{"id" => job_id} = payload, socket) do
    job = UserDocs.Jobs.get_job!(job_id)
    {:ok, job} = UserDocs.Jobs.delete_job(job)
    {:noreply, assign(socket, :job, nil) |> assign(:job_id, nil)}
  end
  def handle_event("create-job", %{"team-id" => team_id} = payload, socket) do
    IO.puts("Create job for #{team_id}")
    {:ok, job} = UserDocs.Jobs.create_job(%{team_id: team_id})
    {:ok, job_instance} =
      job
      |> Map.put(:job_steps, [])
      |> Map.put(:job_processes, [])
      |> UserDocs.JobInstances.create_job_instance()

    {:noreply, job |> assign_job(socket) |> assign(:job_id, job.id)}
  end
  def handle_event("execute-step", %{"id" => step_id} = payload, socket) do
    user_id = socket.assigns.current_user.id |> to_string
    UserDocsWeb.Endpoint.broadcast("user:" <> user_id, "command:execute_step", %{step_id: step_id})
    {:noreply, socket}
  end
  def handle_event("execute-process", %{"id" => process_id} = payload, socket) do
    user_id = socket.assigns.current_user.id |> to_string
    UserDocsWeb.Endpoint.broadcast("user:" <> user_id, "command:execute_process", %{process_id: process_id})
    {:noreply, socket}
  end
  def handle_event("execute-job", _payload, socket) do
    safe_job =
      socket.assigns.job
      |> Automation.Runner.parse()
      |> UserDocsWeb.LiveHelpers.camel_cased_map_keys()

    {
      :noreply,
      socket
      |> Phoenix.LiveView.push_event("executeJob", %{job: safe_job})
   }
  end
  def handle_event("update-step", %{"step" =>
    %{"id" => id, "lastStepInstance" =>
      %{"id" => step_instance_id, "processInstanceId" => nil}
   } = step_attrs}, socket
  ) do
    underscored_step_attrs = UserDocsWeb.LiveHelpers.underscored_map_keys(step_attrs)
    opts = UserDocsWeb.Defaults.opts(socket, types())

    step =
      Jobs.fetch_step_from_job_step(socket.assigns.job, step_instance_id)
      || AutomationManager.get_step!(id)

    changeset = Step.runner_changeset(step, underscored_step_attrs)
    {:ok, updated_step} = UserDocs.Repo.update(changeset)
    UserDocs.Subscription.broadcast_children(updated_step, changeset, opts)
    send(self(), {:broadcast, "update", updated_step})


    job = UserDocs.Jobs.update_job_step_instance(
      socket.assigns.job, updated_step.last_step_instance)

    {:noreply, assign(socket, :job, job)}
  end
  def handle_event("update-step", %{"step" =>
    %{"id" => id, "lastStepInstance" =>
      %{"id" => step_instance_id, "processInstanceId" => process_instance_id}
   } = step_attrs}, socket
  ) do
    step_attrs = UserDocsWeb.LiveHelpers.underscored_map_keys(step_attrs)
    if step_attrs["last_step_instance"]["step_id"] == nil do
      raise "Got a nil step id for some reason, not updating"
    end
    Logger.info("Handling update step #{id} with process instance #{process_instance_id}.  It's step instance is #{step_attrs["last_step_instance"]["id"]}.  We'll set it's status to #{step_attrs["last_step_instance"]["status"]}")
    opts = UserDocsWeb.Defaults.opts(socket, types())

    step =
      Jobs.fetch_step_from_job_processes(socket.assigns.job, process_instance_id, step_instance_id)
      || AutomationManager.get_step!(id)

    changeset = Step.runner_changeset(step, step_attrs)
    {:ok, updated_step} = UserDocs.Repo.update(changeset)
    UserDocs.Subscription.broadcast_children(updated_step, changeset, opts)
    send(self(), {:broadcast, "update", updated_step})

    job = UserDocs.Jobs.update_job_process_instance_step_instance(
      socket.assigns.job, updated_step.last_step_instance)

    {:noreply, assign(socket, :job, job)}
  end
  def handle_event("update-process", %{"process" => %{"id" => id, "lastProcessInstance" => process_instance_attrs} = process_attrs}, socket) do
    Logger.info("Received update-process command for process #{id}")
    opts = UserDocsWeb.Defaults.opts(socket, types())

    updated_job_processes =
      Enum.map(socket.assigns.job.job_processes,
        fn(jp) ->
          if jp.process_instance_id == process_instance_attrs["id"] do

            {:ok, updated_process_instance} =
              UserDocs.ProcessInstances.update_process_instance(jp.process_instance, process_instance_attrs)

            Logger.info("Updated process instance #{updated_process_instance.id} to status #{updated_process_instance.status}")

            send(self(), {:broadcast, "update", updated_process_instance})

            jp
            |> Map.put(:process_instance, updated_process_instance)
          else
            IO.puts("Not on job process")
            jp
          end
        end
      )

    process_instance =
      Enum.reduce(socket.assigns.job.job_processes, nil,
        fn(jp, acc) ->
          if jp.process_instance_id == process_instance_attrs["id"] do
            jp.process_instance
          else
            acc
          end
        end
      )
      || ProcessInstances.get_process_instance!(process_instance_attrs["id"])

    {:ok, updated_process_instance} =
      UserDocs.ProcessInstances.update_process_instance(process_instance, process_instance_attrs)

    send(self(), {:broadcast, "update", updated_process_instance})

    updated_job_processes =
      Enum.map(socket.assigns.job.job_processes,
        fn(jp) ->
          if jp.process_instance_id == process_instance_attrs["id"] do
            Map.put(jp, :process_instance, updated_process_instance)
          else
            jp
          end
        end
      )

    updated_job =
      socket.assigns.job
      |> Map.put(:job_processes, updated_job_processes)

    {:noreply, assign(socket, :job, updated_job)}
  end

  def assign_job(%Jobs.Job{id: id}, socket) do
    job =
      Jobs.get_job!(id, %{preloads: [steps: true, processes: true, last_job_instance: true]})
      |> Jobs.prepare_for_execution()

    assign(socket, :job, job)
  end

  def maybe_update_screenshot(%{"id" => id, "base64" => _} = attrs, team) do
    UserDocs.Screenshots.get_screenshot!(id)
    |> UserDocs.Screenshots.update_screenshot(attrs, team)
  end
  def maybe_update_screenshot(%{"base64" => _} = attrs, team) do
    {:ok, screenshot} = UserDocs.Screenshots.create_screenshot(attrs)
    UserDocs.Screenshots.update_screenshot(screenshot, attrs, team)
  end
  def maybe_update_screenshot(attrs, _team), do: {:ok, attrs}

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

"""
def handle_event("add-process-instance", %{"process-id" => process_id}, socket) do
  case Jobs.add_process_instance_to_job(socket.assigns.job, String.to_integer(process_id)) do
    {:ok, job} -> {:noreply, socket |> assign(:job, Jobs.get_job!(job.id, %{preloads: "*"}))}
    {:error, changeset} ->
      formatted_errors = format_changeset_errors(changeset)
      {:noreply, Phoenix.LiveView.put_flash(socket, :error,  formatted_errors)}
  end
end
def handle_event("remove-process-instance", %{"process-instance-id" => process_instance_id}, socket) do
  case Jobs.remove_process_instance_from_job(socket.assigns.job, String.to_integer(process_instance_id)) do
    {:ok, job} ->
      {:noreply, socket |> assign(:job, job)}
    {:error, changeset} ->
      {:noreply, Phoenix.LiveView.put_flash(socket, :error, "Failed to remove step instance")}
  end
end
def handle_event("create-step-instance", %{"step_instance" => step_instance_attrs} = attrs, socket) do
  IO.inspect(step_instance_attrs)
  {:noreply, socket}
end
"""
"""
def execute_step(socket, %{step_id: step_id}) do
  with step = AutomationManager.get_step!(step_id),
    {:ok, step_instance} = StepInstances.create_step_instance_from_step(step),
    preloaded_step_instance = Map.put(step_instance, :step, step),
    formatted_step_instance = StepInstances.format_step_instance_for_export(preloaded_step_instance)
  do
    socket
    |> Phoenix.LiveView.push_event("execute", %{step_instance: formatted_step_instance})
  else
    _ -> raise("Execute Step Failed in #{__MODULE__}")
  end
end

def execute_process_instance(socket, %{process_id: process_id}, order) do
  socket
  |> UserDocsWeb.ElectronWebDriver.ProcessInstance.execute(process_id, order)
end
"""
"""
def maybe_create_step_instance(%{"step" => %{"step_instance" => step_instance_attrs}} = attrs) do
  IO.inspect("maybe_create_step_instance")
  {:ok, step_instance} = StepInstances.create_step_instance(step_instance_attrs)
  send(self(), {:broadcast, "create", step_instance})
  attrs
end
def maybe_create_step_instance(attrs), do: attrs

def maybe_update_screenshot(%{"step" => %{"screenshot" => %{"id" => id, "base64" => _base64} = screenshot_attrs}} = attrs) do
  IO.inspect("maybe_update_screenshot")
  {:ok, screenshot} =
    UserDocs.Screenshots.get_screenshot!(id)
    |> UserDocs.Screenshots.update_screenshot(screenshot_attrs)

  send(self(), {:broadcast, "update", screenshot})

  attrs
end
def maybe_update_screenshot(attrs), do: attrs

def maybe_create_screenshot(%{"step" => %{"screenshot" => nil}} = attrs) , do: attrs
def maybe_create_screenshot(%{"step" => %{"screenshot" => screenshot_attrs}} = attrs) do
  IO.inspect("maybe_create_screenshot")
  IO.inspect(screenshot_attrs)
  {:ok, screenshot} = UserDocs.Screenshots.create_screenshot(screenshot_attrs)
  send(self(), {:broadcast, "create", screenshot})
  attrs
end
def maybe_create_screenshot(attrs), do: attrs
"""

"""
def maybe_update_step(socket, %{"status" => status, "step_id" => step_id, "attrs" => attrs})
when status == "complete" do
  # {:ok, _step} = update_step_status(step_id, status)
  case attrs["screenshot"] do
    nil -> socket
    %{"id" => id, "base64" => _} = attrs ->
      {:ok, screenshot} = UserDocs.Screenshots.get_screenshot!(id)
      |> UserDocs.Screenshots.update_screenshot(attrs, socket.assigns.current_team)
      send(self(), {:broadcast, "update", screenshot})
      socket
    %{"base64" => _} = attrs ->
      {:ok, screenshot} = UserDocs.Screenshots.create_screenshot(%{step_id: step_id})
      {:ok, screenshot} = UserDocs.Screenshots.update_screenshot(screenshot, attrs, socket.assigns.current_team)
      send(self(), {:broadcast, "update", screenshot})
      socket
  end
end
def maybe_update_step(socket, %{"status" => status, "step_id" => step_id}) when status == "failed" do
  #update_step_status(step_id, status)
  socket
end
def maybe_update_step(socket, _attrs), do: socket

def update_step_status(step_id, status) do
  UserDocs.Automation.get_step!(step_id)
  |> UserDocs.Automation.update_step_status(%{status: status})
end
"""

"""
This was worth a try but I think it's overcommplicated
def handle_event("update-step", %{"step" => %{"id" => id} = step_attrs}, socket) do
  step_attrs = underscored_map_keys(step_attrs)
  opts = UserDocsWeb.Defaults.opts(socket, types())

  step = AutomationManager.get_step!(id)

  step_instance =
    try do
      step_attrs["last_step_instance"]["uuid"]
      |> StepInstances.get_step_instance_by_uuid()
    rescue
      Ecto.NoResultsError ->
        IO.inspect("No step instance found")
        nil
    end

  IO.inspect(step_attrs["last_step_instance"])
  if step_attrs["last_step_instance"]["process_instance_uuid"] do
    IO.puts("We have a process instance id")
  end

  step_attrs =
    if step_instance do
      Kernel.put_in(step_attrs, ["last_step_instance", "id"], step_instance.id)
    else
      step_attrs
    end

  step = Map.put(step, :last_step_instance, step_instance)

  changeset = Step.runner_changeset(step, step_attrs)
  {:ok, updated_step} = UserDocs.Repo.update(changeset)

  UserDocs.Subscription.broadcast_children(updated_step, changeset, opts)
  send(self(), {:broadcast, "update", updated_step})
  {:noreply, socket}
end
def handle_event("update-process", %{"process" => %{"id" => id} = process_attrs}, socket) do
  IO.puts("Update Process")
  process_attrs = underscored_map_keys(process_attrs)
  opts = UserDocsWeb.Defaults.opts(socket, types())
  process = AutomationManager.get_process!(id)

  process_instance =
    try do
      process_attrs["last_process_instance"]["uuid"]
      |> ProcessInstances.get_process_instance_by_uuid!()
    rescue
      Ecto.NoResultsError ->
        IO.inspect("No process instance found")
        nil
    end

  process_attrs =
    if process_instance do
      Kernel.put_in(process_attrs, ["last_process_instance", "id"], process_instance.id)
    else
      process_attrs
    end

  process = Map.put(process, :last_process_instance, process_instance)

  changeset = Process.runner_changeset(process, process_attrs)
  {:ok, updated_process} = UserDocs.Repo.update(changeset)
  UserDocs.Subscription.broadcast_children(updated_process, changeset, opts)
  send(self(), {:broadcast, "update", updated_process})
  {:noreply, socket}
end
"""

"""
Deprecated
def handle_event("add-step-instance", %{"step-id" => step_id}, socket) do
  case Jobs.add_step_instance_to_job(socket.assigns.job, String.to_integer(step_id)) do
    {:ok, job} -> {:noreply, socket |> assign(:job, job)}
    {:error, changeset} ->
      formatted_errors = format_changeset_errors(changeset)
      {:noreply, Phoenix.LiveView.put_flash(socket, :error,  formatted_errors)}
  end
end
def handle_event("remove-step-instance", %{"step-instance-id" => id}, socket) do
  case Jobs.remove_step_instance_from_job(socket.assigns.job, String.to_integer(id)) do
    {:ok, job} ->
      {:noreply, socket |> assign(:job, job)}
    {:error, changeset} ->
      {:noreply, Phoenix.LiveView.put_flash(socket, :error, "Failed to remove step instance")}
  end
end
"""

defmodule UserDocsWeb.AutomationManagerLive.Renderers do
  alias UserDocs.Jobs.JobStep
  alias UserDocs.Jobs.JobProcess
  alias UserDocs.Automation.Step
  alias UserDocs.ProcessInstances.ProcessInstance
  import PhoenixSlime, only: [ sigil_L: 2 ]
  use Phoenix.HTML

  def job_item(object_instance, interactive \\ true)
  def job_item(%JobStep{} = job_step, interactive) do
    ~L"""
    li
      div.is-flex.is-flex-direction-row.is-flex-grow-0
        = link to: "#", phx_click: "delete-job-step", phx_value_id: job_step.id,class: "navbar-item py-0" do
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
  def job_item(%JobProcess{} = job_process, interactive) do
    ~L"""
    li
      input id="expand-job-process-<%= job_process.id %>" class="job-process-toggle" type="checkbox" hidden="true" checked=job_process.collapsed
      .is-flex-direction-column.py-0.job-process
        .is-flex.is-flex-direction-row.is-flex-grow-0.py-0
          = link to: "#", phx_click: "expand-job-process", phx_value_id: job_process.id, class: "navbar-item py-0" do
              span.icon
                i.fa.fa-angle-down.job-process-expanded aria-hidden="true"
          = link to: "#", phx_click: "delete-job-process", phx_value_job_process_id: job_process.id, class: "navbar-item py-0" do
            span.icon
              i.fa.fa-trash aria-hidden="true"
          = link to: "", class: "is-flex-grow-1 py-0" do
            = job_process.order || ""
            | :
            =< job_process.id
        ul.my-0.job-process-steps id="job-process-<%= job_process.id %>-steps"
          = for step <- job_process.process.steps do
            = job_item(step, false)
    """
  end
  def job_item(%Step{} = step, interactive) do
    ~L"""
    li
      div.is-flex.is-flex-direction-row.is-flex-grow-0
        = UserDocsWeb.StepLive.Instance.status(step.last_step_instance)
        = if interactive do
          = link to: "#", phx_click: "remove-step-instance", phx_value_d: step.id,class: "navbar-item py-0" do
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
  def job_item(%ProcessInstance{} = process_instance, interactive) do
    ~L"""
    li
      .is-flex.py-0
        .is-flex.is-flex-direction-row.is-flex-grow-0.py-0
          = link to: "#", phx_click: "remove-process-instance", phx_value_process_instance_id: process_instance.id, class: "navbar-item py-0" do
            span.icon
              i.fa.fa-trash aria-hidden="true"
          = link to: "#", phx_click: "expand-process-instance", phx_value_id: process_instance.id, class: "navbar-item py-0" do
            span.icon
              = if process_instance.expanded do
                i.fa.fa-minus aria-hidden="true"
              - else
                i.fa.fa-plus aria-hidden="true"
          = link to: "#", class: "py-0" do
            = instance_status(process_instance.status)
        = link to: "", class: "is-flex-grow-1 py-0" do
          = process_instance.order || ""
          | :
          =< process_instance.name
      = if process_instance.expanded do
        ul.my-0
          = for step_instance <- process_instance.step_instances do
            = job_item(step_instance, false)
    """
  end


  def instance_status(status) do
    case status do
      "not_started" -> content_tag(:i, "", [class: "fa fa-play-circle", aria_hidden: "true"])
      "failed" -> content_tag(:i, "", [class: "fa fa-times", aria_hidden: "true"])
      "started" -> content_tag(:i, "", [class: "fa fa-spinner", aria_hidden: "true"])
      "complete" -> content_tag(:i, "", [class: "fa fa-check", aria_hidden: "true"])
    end
  end
end

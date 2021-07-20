defmodule UserDocs.Automation.Runner do
  @moduledoc """
    The runner module is basically responsible for converting structs to string key maps for consumption over the wire by hooks
  """
  alias UserDocs.Automation.Step
  alias UserDocs.Automation.Process
  alias UserDocs.Automation.StepType
  alias UserDocs.Web.Annotation
  alias UserDocs.Web.AnnotationType
  alias UserDocs.Web.Element
  alias UserDocs.Web.Strategy
  alias UserDocs.Web.Page
  alias UserDocs.Media.Screenshot
  alias UserDocs.Jobs.JobProcess
  alias UserDocs.Jobs.JobStep
  alias UserDocs.StepInstances.StepInstance
  alias UserDocs.ProcessInstances.ProcessInstance
  alias UserDocs.Jobs.JobInstance
  alias UserDocs.Projects.Version
  alias UserDocs.Projects.Project

  def parse(process = %UserDocs.Automation.Process{}) do
    handlers = %{
      process_instance: &ProcessInstance.safe/2,
      step_instance: &StepInstance.safe/2,
      step: &Step.safe/2,
      annotation: &Annotation.safe/2,
      element: &Element.safe/2,
      step_type: &StepType.safe/2,
      strategy: &Strategy.safe/2,
      annotation_type: &AnnotationType.safe/2,
      page: &Page.safe/2,
      process: &Process.safe/2,
      screenshot: &Screenshot.safe/2,
      version: &Version.safe/2,
      project: &Project.safe/2
    }

    Process.safe(process, handlers)
  end

  def parse(step = %UserDocs.Automation.Step{}) do
    handlers = %{
      step_instance: &StepInstance.safe/2,
      annotation: &Annotation.safe/2,
      element: &Element.safe/2,
      step_type: &StepType.safe/2,
      strategy: &Strategy.safe/2,
      annotation_type: &AnnotationType.safe/2,
      page: &Page.safe/2,
      process: &Process.safe/2,
      screenshot: &Screenshot.safe/2,
      version: &Version.safe/2,
      project: &Project.safe/2
    }

    Step.safe(step, handlers)
  end

  def parse(job = %UserDocs.Jobs.Job{}) do
    handlers = %{
      process_instance: &ProcessInstance.safe/2,
      step_instance: &StepInstance.safe/2,
      job_instance: &JobInstance.safe/2,
      step: &Step.safe/2,
      annotation: &Annotation.safe/2,
      element: &Element.safe/2,
      step_type: &StepType.safe/2,
      strategy: &Strategy.safe/2,
      annotation_type: &AnnotationType.safe/2,
      page: &Page.safe/2,
      process: &Process.safe/2,
      screenshot: &Screenshot.safe/2,
      job_process: &JobProcess.Safe.apply/2,
      job_step: &JobStep.Safe.apply/2
    }

    UserDocs.Jobs.Job.Safe.apply(job, handlers)
  end
end

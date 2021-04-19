defmodule UserDocs.Automation.Runner do
  alias UserDocs.Automation.Step
  alias UserDocs.Automation.Process
  alias UserDocs.Automation.StepType
  alias UserDocs.Web.Annotation
  alias UserDocs.Web.AnnotationType
  alias UserDocs.Web.Element
  alias UserDocs.Web.Strategy
  alias UserDocs.Web.Page
  alias UserDocs.Media.Screenshot

  def parse(process = %UserDocs.Automation.Process{}) do
    handlers = %{
      step: &Step.safe/2,
      annotation: &Annotation.safe/2,
      element: &Element.safe/2,
      step_type: &StepType.safe/2,
      strategy: &Strategy.safe/2,
      annotation_type: &AnnotationType.safe/2,
      page: &Page.safe/2,
    }

    Process.safe(process, handlers)
  end

  def parse(step = %UserDocs.Automation.Step{}) do
    handlers = %{
      annotation: &Annotation.safe/2,
      element: &Element.safe/2,
      step_type: &StepType.safe/2,
      strategy: &Strategy.safe/2,
      annotation_type: &AnnotationType.safe/2,
      page: &Page.safe/2,
      process: &Process.safe/2,
      screenshot: &Screenshot.safe/2
    }

    Step.safe(step, handlers)
  end
end

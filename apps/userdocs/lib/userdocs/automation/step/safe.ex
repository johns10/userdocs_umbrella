defmodule UserDocs.Automation.Step.Safe do

  def apply(step, handlers \\ %{})
  def apply(step = %UserDocs.Automation.Step{}, handlers) do
    element_handlers = %{
      strategy: handlers.strategy
    }
    base_safe(step)
    |> maybe_safe_step_type(handlers[:step_type], step.step_type, handlers)
    |> maybe_safe_annotation(handlers[:annotation], step.annotation, handlers)
    |> maybe_safe_element(handlers[:element], step.element, element_handlers)
    |> maybe_safe_screenshot(handlers[:screenshot], step.screenshot, handlers)
    |> maybe_safe_page(handlers[:page], step.page, handlers)
  end
  def apply(nil, _), do: nil

  defp base_safe(step) do
    %{
      id: step.id,
      order: step.order,
      name: step.name,
      url: step.url,
      text: step.text,
      width: step.width,
      height: step.height,
      page_reference: step.page_reference,
    }
  end

  defp maybe_safe_step_type(step, nil, _, _), do: step
  defp maybe_safe_step_type(step, handler, step_type, handlers) do
    Map.put(step, :step_type, handler.(step_type, handlers))
  end

  defp maybe_safe_annotation(step, nil, _, _), do: step
  defp maybe_safe_annotation(step, handler, annotation, handlers) do
    Map.put(step, :annotation, handler.(annotation, handlers))
  end

  defp maybe_safe_element(step, nil, _, _), do: step
  defp maybe_safe_element(step, handler, element, handlers) do
    Map.put(step, :element, handler.(element, handlers))
  end

  defp maybe_safe_screenshot(step, nil, _, _), do: step
  defp maybe_safe_screenshot(step, handler, screenshot, handlers) do
    Map.put(step, :screenshot, handler.(screenshot, handlers))
  end

  defp maybe_safe_page(step, nil, _, _), do: step
  defp maybe_safe_page(step, handler, page, handlers) do
    Map.put(step, :page, handler.(page, handlers))
  end

end

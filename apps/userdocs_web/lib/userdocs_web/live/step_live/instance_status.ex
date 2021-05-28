defmodule UserDocsWeb.StepLive.Instance do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias UserDocs.StepInstances.StepInstance

  def status(nil) do
    instance = %{status: "none", id: nil, step_id: nil}
    content_tag(:span, span_kwargs(instance)) do
      content_tag(:i, "", icon_kwargs(instance))
    end
  end
  def status(%StepInstance{} = step_instance) do
    content_tag(:span, span_kwargs(step_instance)) do
      content_tag(:i, "", icon_kwargs(step_instance))
    end
  end
  def status(%Ecto.Association.NotLoaded{}) do
    instance = %{status: "failed", id: nil, step_id: nil}
    content_tag(:span, span_kwargs(instance)) do
      content_tag(:i, "", icon_kwargs(instance))
    end
  end

  def icon_kwargs(step_instance) do
    [ aria_hidden: "true" ]
    |> icon_class(step_instance.status)
  end

  def span_kwargs(step_instance) do
    []
    |> tooltip(step_instance.status, step_instance.id, step_instance.step_id)
  end

  def icon_class(base, "none"), do: base ++ [ class: "fa fa-ban" ]
  def icon_class(base, "warn"), do: base ++ [ class: "fas fa-exclamation-triangle" ]
  def icon_class(base, "not_started"), do: base ++ [ class: "fa fa-minus" ]
  def icon_class(base, "failed"), do: base ++ [ class: "fa fa-times" ]
  def icon_class(base, "started"), do: base ++ [ class: "fa fa-spinner" ]
  def icon_class(base, "complete"), do: base ++ [ class: "fa fa-check" ]

  def tooltip(base, "warn", _id, _step_id), do: base ++ [ data_tooltip: "fa fa-check" ]
  def tooltip(base, "not_started", id, step_id), do: base ++ [ data_tooltip: "Step Instance #{id} (step #{step_id}) hasn't started running yet.  Start your job." ]
  def tooltip(base, "none", _id, _step_id), do: base ++ [ data_tooltip: "There's no status element for this step. Reinitialize this job." ]
  def tooltip(base, _, _, _), do: base

  def render_errors(nil), do: ""
  def render_errors(errors) do
    Enum.reduce(errors, "",
      fn(error, acc) ->
        acc <> render_error(error)
      end
    )
  end

  def render_error(error) do
    Enum.reduce(error, "",
      fn({ k, v }, acc ) ->
        acc <> k <> ": " <> to_string(v) <> "\n"
      end
    )
  end

  def step_instances_status([ _ | _ ] = items) do
    Enum.reduce(items, nil, fn(step_instance, acc) ->
      case step_instance.status do
        "failed" -> "warn"
        "not_started" -> "warn"
        _ -> acc
      end
    end)
  end
  def step_instances_status([]), do: :ok
end

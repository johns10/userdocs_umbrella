defmodule UserDocsWeb.ProcessLive.Instance do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias UserDocs.ProcessInstances.ProcessInstance

  def status(nil) do
    instance = %{ status: "none", id: nil, step_id: nil }
    content_tag(:span, span_kwargs(instance)) do
      content_tag(:i, "", icon_kwargs(instance))
    end
  end
  def status(%ProcessInstance{} = process_instance) do
    content_tag(:span, span_kwargs(process_instance)) do
      content_tag(:i, "", icon_kwargs(process_instance))
    end
  end
  def status(%Ecto.Association.NotLoaded{}) do
    instance = %{ status: "none", id: nil, step_id: nil }
    content_tag(:span, span_kwargs(instance)) do
      content_tag(:i, "", icon_kwargs(instance))
    end
  end

  def icon_kwargs(process_instance) do
    [ aria_hidden: "true" ]
    |> icon_class(process_instance.status)
  end

  def span_kwargs(process_instance) do
    []
    |> tooltip(process_instance)
  end

  def icon_class(base, "none"), do: base ++ [ class: "fa fa-ban" ]
  def icon_class(base, "warn"), do: base ++ [ class: "fas fa-exclamation-triangle" ]
  def icon_class(base, "not_started"), do: base ++ [ class: "fa fa-minus" ]
  def icon_class(base, "failed"), do: base ++ [ class: "fa fa-times" ]
  def icon_class(base, "started"), do: base ++ [ class: "fa fa-spinner" ]
  def icon_class(base, "complete"), do: base ++ [ class: "fa fa-check" ]

  def tooltip(base, %{ status: "warn" }), do: base ++ [ data_tooltip: "fa fa-check" ]
  def tooltip(base, %{ status: "not_started", id: id }), do: base ++ [ data_tooltip: "Process Instance #{id} hasn't started running yet.  Start your job." ]
  def tooltip(base, %{ status: "none", id: id, step_id: step_id }), do: base ++ [ data_tooltip: "There's no status element for this process. Reinitialize this job." ]
  def tooltip(base, _), do: base

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

  def process_instances_status([ _ | _ ] = items) do
    Enum.reduce(items, nil, fn(process_instance, acc) ->
      case process_instance.status do
        "failed" -> "warn"
        "not_started" -> "warn"
        _ -> acc
      end
    end)
  end
  def process_instances_status([]), do: :ok
end

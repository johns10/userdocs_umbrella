defmodule UserDocsWeb.StepLive.Status do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:errors, [])
      |> assign(:status, :ok)
    }
  end

  @impl true
  def render(assigns) do
    ~L"""
    <%= content_tag(:div, status_opts(@status, @errors, @id)) do %>

      <span class="icon">
        <%= status_icon(@status) %>
      </span>

    <%= end %>
    """
  end

  @impl true
  def handle_event("update_step", %{ "status" => status } = payload, socket) do
    {
      :noreply,
      socket
      |> assign(:status, String.to_atom(status))
      |> assign(:errors, payload["errors"])
      |> assign(:warnings, payload["warnings"])
    }
  end

  def status_icon(:ok), do: ""
  def status_icon(:failed), do: content_tag(:i, "", [class: "fa fa-times", aria_hidden: "true"])
  def status_icon(:warn), do: content_tag(:i, "", [class: "fa fa-exlamation-triangle", aria_hidden: "true"])
  def status_icon(:started), do: content_tag(:i, "", [class: "fa fa-spinner", aria_hidden: "true"])
  def status_icon(:complete), do: content_tag(:i, "", [class: "fa fa-check", aria_hidden: "true"])

  def status_opts(status, _errors, id) when status in [ :ok, :started, :complete ] do
    [ id: id, class: "navbar-item", phx_hook: "stepStatus" ]
  end
  def status_opts(status, errors, id) when status in [ :failed, :warn ] do
    [
      id: id,
      class: "navbar-item has-tooltip-left",
      data_tooltip: render_errors(errors),
      phx_hook: "stepStatus"
    ]
  end

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
end

defmodule UserDocsWeb.StepLive.IndexComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.StepLive.Runner
  alias UserDocsWeb.StepLive.FormComponent, as: StepForm
  alias UserDocs.Automation.Process.RecentPage

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  def is_expanded?(expanded, id) do
    Map.get(expanded, id, false)
    |> case do
      true -> ""
      false -> "is-hidden"
    end
  end
end

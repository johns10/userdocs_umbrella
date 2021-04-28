defmodule UserDocsWeb.ScreenshotLive.Approve do
  use UserDocsWeb, :live_component

  alias UserDocs.Screenshots

  @impl true
  def update(%{ step: %{ process_id: process_id, screenshot: screenshot }, team: team }, socket) do
    {
      :ok,
      socket
      |> assign(:screenshot, screenshot)
      |> assign(:process_id, process_id)
      |> assign(:team, team)
      |> assign_url(screenshot, :aws_screenshot, team)
      |> assign_url(screenshot, :aws_provisional_screenshot, team)
      |> assign_url(screenshot, :aws_diff_screenshot, team)
    }
  end

  def assign_url(socket, screenshot, key, team) do
    case Screenshots.get_url(Map.get(screenshot, key), team) do
      { :ok, url } -> assign(socket, key, url)
      _ -> socket
    end
  end

  @impl true
  def handle_event("approve-provisional", _, %{ assigns: %{ screenshot: screenshot, team: team } } = socket) do
    updated_screenshot = Screenshots.apply_provisional_screenshot(screenshot, team)
    send(self(), { :broadcast, "update", updated_screenshot })
    {
      :noreply,
      socket
      |> push_patch(to: Routes.step_index_path(socket, :index, socket.assigns.process_id))
    }
  end
  def handle_event("reject-provisional", _, %{ assigns: %{ screenshot: screenshot } } = socket) do
    updated_screenshot = Screenshots.reject_provisional_screenshot(screenshot)
    send(self(), { :broadcast, "update", updated_screenshot })
      {
        :noreply,
        socket
        |> push_patch(to: Routes.step_index_path(socket, :index, socket.assigns.process_id))
      }
  end
  def handle_event("cancel-review", _, %{ assigns: %{ screenshot: screenshot } } = socket) do
      {
        :noreply,
        socket
        |> push_patch(to: Routes.step_index_path(socket, :index, socket.assigns.process_id))
      }
  end
end

defmodule UserDocsWeb.JobLive.Show do
  use UserDocsWeb, :live_view

  alias UserDocs.Jobs

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:job, Jobs.get_job!(id))}
     |> assign(url: URI.parse(url))
  end

  defp page_title(:show), do: "Show Job"
  defp page_title(:edit), do: "Edit Job"
end

defmodule UserDocsWeb.ServicesLive.StatusComponent do
  @moduledoc """
  Form for signing in to userdocs
  """
  use UserDocsWeb, :live_component

  @status_map %{
    "not_running" => :error,
    "running" => :ok,
    "" => :error,
    "initialized with schema" => :ok
  }

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:server_status, "not_running")
      |> assign(:client_status, "not_running")
      |> assign(:runner_status, "not_running")
    }
  end

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
    }
  end

  @impl true
  def handle_event("put-services-status", params, socket) do
    {
      :noreply,
      socket
      |> client_status(params["client"])
      |> runner_status(params["server"])
      |> server_status(params["runner"])
    }
  end

  def status_element(symbol, status, id) do
    class = status_class(Map.get(@status_map, status))
    content_tag(:div, id: id, class: class, data_status: status) do
      symbol
    end
  end
  def status_class(:ok), do: "rounded-full bg-green-600 text-white h-3 w-3 flex items-center justify-center text-sm m-0.5"
  def status_class(:error), do: "rounded-full bg-red-600 text-white h-3 w-3 flex items-center justify-center text-sm m-0.5"

  def client_status(socket, status), do: assign(socket, :client_status, status)
  def runner_status(socket, status), do: assign(socket, :runner_status, status)
  def server_status(socket, status), do: assign(socket, :server_status, status)
end

defmodule UserDocsWeb.StepLive.BrowserEvents do
  require Logger
  alias UserDocs.Automation
  alias UserDocs.Web

  def step_type(%{ "action" => "ITEM_SELECTED" }), do: nil
  def step_type(payload) do
    Automation.list_step_types(%{ filters: [ name: payload["action"] ]})
    |> Enum.at(0)
  end

  def params(%{ payload: %{ "action" => "Navigate", "href" => href }, step_type: step_type }) do
    IO.inspect("Navigate Event")
    %{
      step_type_id: step_type.id,
      page_reference: "page",
      page_id: nil,
      page: %{
        url: href
      }
    }
  end
  def params(%{ payload: %{ "action" => "Click", "selector" => selector }, step_type: step_type, page_id: page_id }) do
    IO.inspect("Click Event")
    IO.inspect(step_type)
    %{
      step_type_id: step_type.id,
      page_id: page_id,
      element: %{
        page_id: page_id,
        strategy_id: Web.css_strategy() |> Map.get(:id),
        selector: selector
      }
    }
  end
  def params(%{ payload: %{ "action" => "ITEM_SELECTED", "selector" => selector }}) do
    IO.inspect("Item Selected Event")
    %{ element: %{ selector: selector } }
  end
  def params(%{ payload: %{ "action" => "CREATE_ANNOTATION" }}) do
    IO.inspect("Annotation Event")
  end

  def form_tweaks(socket, %{ payload: %{ "action" => "Click" }}) do
    IO.puts("Adding new element")
    socket
  end
  def form_tweaks(socket, %{ payload: %{ "action" => "Navigate" }} = state) do
    IO.puts("Navigate")
    socket
  end
  def form_tweaks(socket, %{ payload: %{ "action" => "ITEM_SELECTED" }} = state) do
    IO.puts("Item Selected")
    socket
  end

  def handle_action(%Phoenix.LiveView.Socket{ assigns: %{ live_action: :index }} = socket, %{} = params) do
    route = UserDocsWeb.Router.Helpers.step_index_path(socket, :new, socket.assigns.process, %{ step_params: params })
    IO.puts("Its in index mode, pushing to #{route}")
    socket
    |> Phoenix.LiveView.push_patch(to: route)
  end
  def handle_action(%Phoenix.LiveView.Socket{ assigns: %{ live_action: :new }} = socket, %{} = params) do
    route = UserDocsWeb.Router.Helpers.step_index_path(socket, :new, socket.assigns.process, %{ step_params: params })
    socket
    |> Phoenix.LiveView.push_patch(to: route)
  end
  def handle_action(%Phoenix.LiveView.Socket{ assigns: %{ live_action: :edit }} = socket, %{} = params) do
    IO.puts("Its in edit mode")
    socket
    |> Phoenix.LiveView.assign(:step_params, params)
  end
  def handle_action(%Phoenix.LiveView.Socket{ assigns: %{ live_action: action }} = socket, %{} = params) do
    throw("Action handler not implemented for #{action}")
  end
  def handle_action(socket, %{} = params) do
    IO.inspect(socket)
    throw("Action Probably not on socket")
  end

end

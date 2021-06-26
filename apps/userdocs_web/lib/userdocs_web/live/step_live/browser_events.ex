defmodule UserDocsWeb.StepLive.BrowserEvents do
  require Logger
  alias Phoenix.LiveView.Socket
  alias UserDocs.Automation
  alias UserDocs.Web

  def step_type_id(payload) do
    step_type(payload)
    |> Map.get(:id, nil)
  end
  def step_type(%{ "action" => "ITEM_SELECTED" }), do: nil
  def step_type(payload) do
    Automation.list_step_types(%{ filters: [ name: payload["action"] ]})
    |> Enum.at(0)
  end

  def annotation_type_id(payload) do
    annotation_type(payload)
    |> Map.get(:id, nil)
  end
  def annotation_type(payload) do
    Web.list_annotation_types()
    |> Enum.filter(fn(at) -> at.name == payload["annotation_type"] end)
    |> Enum.at(0)
  end

  def params(%{ payload: %{ "action" => "Navigate", "href" => href } = payload }) do
    IO.inspect("Navigate Event")
    %{
      "step_type_id" => step_type_id(payload),
      "page_reference" => "page",
      "page_id" => nil,
      "page" => %{
        "url" => href
      }
    }
  end
  def params(%{ payload: %{ "action" => "Click", "selector" => selector } = payload, page_id: page_id }) do
    IO.inspect("Click Event")
    %{
      "step_type_id" => step_type_id(payload),
      "page_id" => page_id,
      "element" => %{
        "page_id" => page_id,
        "strategy_id" => Web.css_strategy() |> Map.get(:id),
        "selector" => selector
      }
    }
  end
  def params(%{ payload: %{ "action" => "Element Screenshot", "selector" => selector } = payload, page_id: page_id }) do
    IO.inspect("Click Event")
    %{
      "step_type_id" => step_type_id(payload),
      "page_id" => page_id,
      "element" => %{
        "page_id" => page_id,
        "strategy_id" => Web.css_strategy() |> Map.get(:id),
        "selector" => selector
      }
    }
  end
  def params(%{ payload: %{ "action" => "Apply Annotation", "selector" => selector } = payload, page_id: page_id }) do
    IO.inspect("Apply Annotation Event")
    %{
      "step_type_id" => step_type_id(payload),
      "page_id" => page_id,
      "element" => %{
        "page_id" => page_id,
        "strategy_id" => Web.css_strategy() |> Map.get(:id),
        "selector" => selector
      },
      "annotation" => %{
        "page_id" => page_id,
        "annotation_type_id" => annotation_type_id(payload)
      }
    }
  end
  def params(%{ payload: %{ "action" => "ITEM_SELECTED", "selector" => selector }, page_id: page_id }) do
    IO.inspect("Item Selected Event")
    %{
      "page_id" => page_id,
      "action" => "item_selected",
      "element" => %{
        "page_id" => page_id,
        "selector" => selector
      }
    }
  end

  def handle_action(%Socket{ assigns: %{ live_action: :index }} = socket, %{ "action" => "item_selected" }), do: socket
  def handle_action(%Socket{ assigns: %{ live_action: action }} = socket, %{ "action" => "item_selected" } = params) when action in [ :new, :edit ] do
    Phoenix.LiveView.assign(socket, :step_params, params)
  end
  def handle_action(%Socket{ assigns: %{ live_action: :index }} = socket, %{} = params) do
    route = UserDocsWeb.Router.Helpers.step_index_path(socket, :new, socket.assigns.process, %{ step_params: params })
    socket
    |> Phoenix.LiveView.push_patch(to: route)
  end
  def handle_action(%Socket{ assigns: %{ live_action: :new }} = socket, %{} = params) do
    IO.puts("Handle action on a new form, adding in the params")
    socket
    |> Phoenix.LiveView.assign(:step_params, params)
  end
  def handle_action(%Socket{ assigns: %{ live_action: :edit }} = socket, %{} = params) do
    socket
    |> Phoenix.LiveView.assign(:step_params, params)
  end
  def handle_action(%Socket{ assigns: %{ live_action: action }}, _params) do
    throw("Action handler not implemented for #{action}")
  end
  def handle_action(socket, _params) do
    IO.inspect(socket)
    throw("Action Probably not on socket")
  end

end

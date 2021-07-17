defmodule UserDocsWeb.StepLive.BrowserEvents do
  @moduledoc """
    This module handles events pushed from the browser into the LiveView application, most noteably, authoring events that occur in the extension
    The module assigns step_params to the socket. step_params is used in `StepLive.FormComponent` to do the things.
  """
  require Logger
  alias Phoenix.LiveView.Socket
  alias UserDocs.Automation
  alias UserDocs.Web
  alias UserDocsWeb.Router.Helpers

  def handle(socket, state) do
    step_params = params(state)
    handle_action(socket, step_params)
  end

  defp handle_action(%Socket{assigns: %{live_action: :index}} = socket, %{"action" => "item_selected"}), do: socket
  defp handle_action(%Socket{assigns: %{live_action: action}} = socket, %{"action" => "item_selected"} = params) when action in [:new, :edit] do
    Phoenix.LiveView.assign(socket, :step_params, params)
  end
  defp handle_action(%Socket{assigns: %{live_action: :index}} = socket, %{} = params) do
    route = Helpers.step_index_path(socket, :new, socket.assigns.process, %{step_params: params})
    socket
    |> Phoenix.LiveView.push_patch(to: route)
  end
  defp handle_action(%Socket{assigns: %{live_action: :new}} = socket, %{} = params) do
    socket
    |> Phoenix.LiveView.assign(:step_params, params)
  end
  defp handle_action(%Socket{assigns: %{live_action: :edit}} = socket, %{} = params) do
    socket
    |> Phoenix.LiveView.assign(:step_params, params)
  end
  defp handle_action(%Socket{assigns: %{live_action: action}}, _params) do
    throw("Action handler not implemented for #{action}")
  end
  defp handle_action(_socket, _params) do
    throw("Action Probably not on socket")
  end

  def step_type_id(payload) do
    step_type(payload)
    |> Map.get(:id, nil)
  end
  def step_type(%{"action" => "ITEM_SELECTED"}), do: nil
  def step_type(payload) do
    Automation.list_step_types(%{filters: [name: payload["action"]]})
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

  defp params(%{payload: %{"action" => "Navigate", "href" => href} = payload}) do
    %{
      "step_type_id" => step_type_id(payload),
      "page_reference" => "page",
      "page_id" => nil,
      "page" => %{
        "url" => href
      }
    }
  end
  defp params(%{payload: %{"action" => "Click", "selector" => selector} = payload, page_id: page_id}) do
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
  defp params(%{payload: %{"action" => "Element Screenshot", "selector" => selector} = payload, page_id: page_id}) do
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
  defp params(%{payload: %{"action" => "Apply Annotation", "selector" => selector} = payload, page_id: page_id}) do
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
  defp params(%{payload: %{"action" => "ITEM_SELECTED", "selector" => selector} = payload, page_id: page_id}) do
    %{
      "step_type_id" => step_type_id(payload),
      "page_id" => page_id,
      "action" => "item_selected",
      "element" => %{
        "page_id" => page_id,
        "selector" => selector
      }
    }
  end
end

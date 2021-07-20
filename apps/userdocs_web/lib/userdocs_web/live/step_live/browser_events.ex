defmodule UserDocsWeb.StepLive.BrowserEvents do
  @moduledoc """
    This module handles events pushed from the browser into the LiveView application, most noteably, authoring events that occur in the extension
    The module assigns step_params to the socket. step_params is used in `StepLive.FormComponent` to do the things.
  """
  require Logger
  alias UserDocs.Automation
  alias UserDocs.Web

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

  def params(%{payload: %{"action" => "Navigate", "href" => href} = payload}) do
    %{
      "step_type_id" => step_type_id(payload),
      "page_reference" => "page",
      "page_id" => nil,
      "page" => %{
        "url" => href
      }
    }
  end
  def params(%{payload: %{"action" => "Click", "selector" => selector} = payload, page_id: page_id}) do
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
  def params(%{payload: %{"action" => "Element Screenshot", "selector" => selector} = payload, page_id: page_id}) do
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
  def params(%{payload: %{"action" => "Apply Annotation", "selector" => selector} = payload, page_id: page_id}) do
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
  def params(%{payload: %{"action" => "ITEM_SELECTED", "selector" => selector} = payload, page_id: page_id}) do
    %{
      "step_type_id" => "do_not_update",
      "page_id" => page_id,
      "action" => "item_selected",
      "element" => %{
        "page_id" => page_id,
        "selector" => selector
      }
    }
  end
end

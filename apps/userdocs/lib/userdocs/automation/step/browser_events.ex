defmodule UserDocs.Automation.Step.BrowserEvents do
  @moduledoc """
    This module handles events pushed from the browser into the LiveView application, most noteably, authoring events that occur in the extension
    The module assigns step_params to the socket. step_params is used in `StepLive.FormComponent` to do the things.
  """
  require Logger
  alias UserDocs.Automation
  alias UserDocs.Automation.Step
  alias UserDocs.Automation.StepForm
  alias UserDocs.Projects.Project
  alias UserDocs.Web
  alias UserDocs.Web.Element
  alias UserDocs.Web.Page


  alias UserDocsWeb.StepLive.FormComponent.Helpers

  def cast(%{"action" => "Navigate", "href" => href, "page_title" => page_title, "order" => order} = payload) do
    %{
      "action" => "navigate",
      "order" => order,
      "step_type_id" => step_type_id(payload),
      "page_reference" => "page",
      "page_id" => nil,
      "page" => %{
        "url" => href,
        "name" => page_title
      }
    }
  end
  def cast(%{"action" => "Click", "href" => href, "selector" => selector, "element_name" => element_name, "order" => order} = payload) do
    %{
      "action" => "click",
      "order" => order,
      "step_type_id" => step_type_id(payload),
      "element" => %{
        "strategy_id" => Web.css_strategy() |> Map.get(:id),
        "selector" => selector,
        "name" => element_name
      },
      "page" => %{
        "url" => href
      }
    }
  end
  def cast(%{"action" => "Element Screenshot", "href" => href, "selector" => selector, "element_name" => element_name, "order" => order} = payload) do
    %{
      "action" => "element_screenshot",
      "order" => order,
      "step_type_id" => step_type_id(payload),
      "element" => %{
        "strategy_id" => Web.css_strategy() |> Map.get(:id),
        "selector" => selector,
        "name" => element_name
      },
      "page" => %{
        "url" => href
      }
    }
  end
  def cast(%{"action" => "Full Screen Screenshot", "href" => href, "order" => order} = payload) do
    %{
      "action" => "full_screen_screenshot",
      "order" => order,
      "step_type_id" => step_type_id(payload),
      "page" => %{
        "url" => href
      }
    }
  end
  def cast(%{"action" => "Apply Annotation", "href" => href, "selector" => selector, "element_name" => element_name, "order" => order, "label" => label} = payload) do
    %{
      "action" => "apply_annotation",
      "order" => order,
      "step_type_id" => step_type_id(payload),
      "element" => %{
        "strategy_id" => Web.css_strategy() |> Map.get(:id),
        "selector" => selector,
        "name" => element_name
      },
      "annotation" => %{
        "annotation_type_id" => annotation_type_id(payload),
        "label" => label
      },
      "page" => %{
        "url" => href
      }
    }
  end
  def cast(%{"action" => "ITEM_SELECTED", "href" => href, "selector" => selector, "element_name" => element_name, "order" => order}) do
    %{
      "action" => "item_selected",
      "order" => order,
      "element" => %{
        "strategy_id" => Web.css_strategy() |> Map.get(:id),
        "selector" => selector,
        "name" => element_name
      },
      "page" => %{
        "url" => href
      }
    }
  end
  def cast(%{"action" => "Fill Field", "href" => href, "selector" => selector, "value" => value, "element_name" => element_name, "order" => order} = payload) do
    %{
      "action" => "fill_field",
      "order" => order,
      "step_type_id" => step_type_id(payload),
      "text" => value,
      "element" => %{
        "strategy_id" => Web.css_strategy() |> Map.get(:id),
        "selector" => selector,
        "name" => element_name
      },
      "page" => %{
        "url" => href
      }
    }
  end
  def cast(%{"action" => "save_step"}), do: %{"action" => "save_step"}

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

  def action(live_action, browser_action) do
    case {live_action, browser_action} do
      {:index, "ITEM_SELECTED"} -> :new
      {_, "save_step"} -> :save
      {live_action, _} -> live_action
    end
  end

  def enable_step_form_fields(step_form, assigns) do
    step_form
    |> Helpers.enabled_step_fields(assigns)
    |> Helpers.enabled_annotation_fields(assigns)
  end

  def handle_page(%{"action" => _, "page" => %{"url" => url}} = params, project) do
    uri = URI.parse(url)
    project_uri = URI.parse(project.base_url)
    case uri.host == project_uri.host do
      true ->
        IO.puts("Project host matches current host")
        params = cast_url(params, :relative)
        case find_page(project.pages, url) do
          %Page{} = page ->
            IO.puts("URL matches existing page")
            update_params_to_existing_page(params, page)
          nil ->
            IO.puts("Not Found page")
            update_params_for_new_page(params)
        end
      false ->
        IO.puts("Project host doesn't match current host")
        params = cast_url(params, :full_uri)
        case find_page(project.pages, url) do
          %Page{} = page ->
            IO.puts("URL matches existing page")
            update_params_to_existing_page(params, page)
          nil ->
            IO.puts("Not Found page")
            params
        end
    end
  end

  def cast_url(%{"action" => "navigate", "page" => %{"url" => url} = page_params} = params, :relative) do
    inner_page_params = Map.put(page_params, "url", URI.parse(url).path)
    Map.put(params, "page", inner_page_params)
  end
  def cast_url(params, _), do: params

  def update_params_to_existing_page(params, page) do
    #IO.puts("update_params_to_existing_page: #{page.id}")
    params
    |> Map.put("page_id", page.id)
    |> maybe_put_page_params(page)
    |> maybe_put_element_page_id(page)
    |> maybe_put_annotation_page_id(page)
  end

  def maybe_put_page_params(%{"action" => "navigate"} = params, page),
    do: Map.put(params, "page", get_params(page, Page))
  def maybe_put_page_params(%{"action" => _, "page" => page_params} = params, _),
    do: Map.delete(params, "page")

  def maybe_put_element_page_id(%{"element" => element_params} = params, page),
    do: Map.put(params, "element", Map.put(element_params, "page_id", page.id))
  def maybe_put_element_page_id(params, _), do: params


  def maybe_put_annotation_page_id(%{"annotation" => annotation_params} = params, page),
    do: Map.put(params, "annotation", Map.put(annotation_params, "page_id", page.id))
  def maybe_put_annotation_page_id(params, _), do: params

  def update_params_for_new_page(%{"action" => "navigate"} = params), do: params
  def update_params_for_new_page(params), do: params |> Map.delete("page")

  def handle_element(%{"element" => %{"selector" => selector}, "page_id" => page_id} = params, elements) do
    result = Enum.filter(elements, fn(element) -> element.page_id == page_id && element.selector == selector end)
    case result do
      [] = elements when elements == [] ->
        params
        |> Map.put("element_id", "")
      [%{id: element_id} = element | _] ->
        element_params = get_params(element, Element)
        params
        |> Map.put("element_id", element_id)
        |> Map.put("element", element_params)
    end
  end
  def handle_element(params, _), do: params

  def get_params(struct, type) do
    Map.take(struct, type.__schema__(:fields))
    |> Enum.reduce(%{}, fn({k, v}, e) -> Map.put(e, to_string(k), v) end)
    |> Map.delete("inserted_at") |> Map.delete("updated_at")
  end

  def find_page(pages, url) do
    uri = URI.parse(url)
    pages
    |> Enum.filter(fn(page) ->
      URI.parse(page.url).path == uri.path
    end)
    |> Enum.at(0)
  end

  def find_project(projects, url) do
    uri = URI.parse(url)
    Enum.filter(projects, fn(project) ->
      inner_uri = URI.parse(project.base_url)
      uri.scheme == inner_uri.scheme && uri.host == inner_uri.host
    end)
    |> case do
      [] = projects when projects == [] -> nil
      [%{id: _, base_url: _, pages: _} = project | _] -> project
    end
  end

  def recent_navigated_page_id(steps) do
    Enum.reduce(steps, nil, fn(step, acc) ->
      case step do
        %Step{step_type: %{name: "Navigate"}, page_id: page_id} -> page_id
        %Step{step_type: %{name: _}} -> acc
      end
    end)
  end
end

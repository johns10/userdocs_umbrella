defmodule UserDocs.Automation.Process.RecentPage do

  require Logger

  alias UserDocs.Web.Page
  alias UserDocs.Automation.Step
  alias UserDocs.Automation.Process

  @doc """
  Takes a process, with steps preloaded, and a list of available pages.
  Locates the last navigated to page.  For example:

    RecentPage.get(page, socket.assigns.data.pages)
  """
  def get_id(process, current_step, [%Page{} | _] = pages) do
    case get(process, current_step, [%Page{} | _] = pages) do
      nil -> nil
      %Page{} = page ->
        Map.get(page, :id)
    end
  end
  def get_id(_, _, []), do: nil

  def get(%Process{steps: [] = steps}, current_step, pages) do
    get(steps, current_step, pages)
  end
  def get(%Process{steps: [%Step{} | _] = steps}, current_step, [%Page{} | _] = pages) do
    get(steps, current_step, pages)
  end
  def get([%Step{} | _] = steps, current_step, [%Page{} | _] = pages) do
    _step =
      case recent_navigation_step(current_step, steps) do
        None ->
          Logger.debug("Failed to fetch most recent navigation step")
          %UserDocs.Web.Page{}

        %UserDocs.Automation.Step{} = step ->
          # Logger.debug("Fetched most recent navigation step, page_id: #{step.page_id}")
          _page =
            pages
            |> Enum.filter(fn(page) -> page.id == step.page_id end)
            |> Enum.at(0)
      end
  end
  def get([], _, _), do: %UserDocs.Web.Page{}

  # Takes a list of steps, returns the most recent step of type "Navigate"
  defp recent_navigation_step(step, steps) do
    navigation_steps = Enum.filter(steps,
      fn(s) ->
        s.step_type.name == "Navigate" && s.order < step.order
      end)

    try do
      Enum.max_by(navigation_steps,
      fn(step) ->
        step.order || 0
      end)
    rescue
      EmptyError -> None
      _ -> None
    end
  end
end

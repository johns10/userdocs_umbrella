defmodule UserDocs.Automation.Process.RecentPage do

  require Logger

  alias UserDocs.Web.Page

  @doc """
  Takes a process, with steps preloaded, and a list of available pages.
  Locates the last navigated to page.  For example:

    RecentPage.get(page, socket.assigns.data.pages)
  """
  def get_id(process, current_step, [ %Page{} | _ ] = pages) do
    case get(process, current_step, [ %Page{} | _ ] = pages) do
      nil -> nil
      %Page{} = page ->
        Map.get(page, :id)
    end
  end

  def get(process, current_step, [ %Page{} | _ ] = pages) do
    steps = process.steps

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

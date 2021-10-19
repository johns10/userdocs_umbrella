defmodule UserDocsWeb.API.Resolvers.Page do

  alias UserDocs.Automation.Step

  def get_page!(%Step{ page: %UserDocs.Pages.Page{} = page }, _args, _resolution) do
    IO.puts("Get page call where the parent is step, and it has a preloaded page")
    { :ok, page }
  end
  def get_page!(%Step{ page: nil, page_id: nil }, _args, _resolution) do
    IO.puts("Get page call where the parent is step, and the page_id is nil")
    { :ok, nil }
  end

end

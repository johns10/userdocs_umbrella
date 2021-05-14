defmodule UserDocsWeb.API.Resolvers.Element do

  alias UserDocs.Web.Element
  alias UserDocs.Automation.Step

  def get_element!(%Step{ element: %Element{} = element }, _args, _resolution) do
    IO.puts("Get element call where the parent is step, and it has a preloaded page")
    { :ok, element }
  end
  def get_element!(%Step{ element: nil, element_id: nil }, _args, _resolution) do
    IO.puts("Get element call where the parent is step, and the element_id is nil")
    { :ok, nil }
  end

end

defmodule UserDocsWeb.API.Resolvers.Version do
  @moduledoc false
  alias UserDocs.Projects.Version
  alias UserDocs.Web.Page

  def get_version!(%Page{version: %Version{} = version}, _args, _resolution) do
    IO.puts("Get version call where the parent is page, and it has a preloaded version")
    {:ok, version}
  end
end

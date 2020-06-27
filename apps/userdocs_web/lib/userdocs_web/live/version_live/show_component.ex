defmodule UserDocsWeb.VersionLive.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Web

  alias UserDocsWeb.PageLive.ShowComponent
  alias UserDocsWeb.PageLive.FormComponent

  @impl true
  def render(assigns) do
    ~L"""
    <div class="card">
      <header class="card-header">
        <p class="card-header-title">
          <%= @version.name %>
        </p>
      </header>
      <%= live_group(@socket, ShowComponent, FormComponent,
        [
          title: "Pages",
          type: :page,
          parent_type: :version,
          struct: %Web.Page{},
          objects: @version.pages,
          return_to: Routes.page_index_path(@socket, :index),
          id: "version-" <> Integer.to_string(@version.id) <> "-pages",
          parent: @version
        ]
      ) %>
    </div>
    """
  end
end

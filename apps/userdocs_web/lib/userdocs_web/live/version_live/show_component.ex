defmodule UserDocsWeb.VersionLive.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Web
  alias UserDocs.Projects
  alias UserDocs.Documents
  alias UserDocs.Automation

  alias UserDocs.Web.Page

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
          struct: %Page{},
          objects: @version.pages,
          return_to: Routes.page_index_path(@socket, :index),
          id: "version-" <> Integer.to_string(@version.id) <> "-pages",
          parent: @version,
          select_lists: %{
            available_versions: @available_versions,
            available_pages: @version.pages,
            available_step_types: @available_step_types
          }
        ]
      ) %>
    </div>
    """
  end


  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:available_step_types, step_types())
      |> assign(:available_content, available_content())

    {:ok, socket}
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:version, None)

    {:ok, socket}
  end

  defp step_types do
    Automation.list_step_types()
  end

  defp available_content() do
    Documents.list_content()
  end
end

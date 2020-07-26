defmodule UserDocsWeb.VersionLive.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Documents
  alias UserDocs.Automation

  alias UserDocs.Web
  alias UserDocs.Web.Page

  alias UserDocs.Projects

  alias UserDocsWeb.PageLive
  alias UserDocsWeb.ProcessLive

  alias UserDocs.Automation.Process

  @impl true
  def render(assigns) do
    ~L"""
    <div class="card">
      <header class="card-header">
        <p class="card-header-title">
          <%= @version.name %>
        </p>
      </header>
      <%= live_group(@socket, ProcessLive.Header, ProcessLive.ShowComponent, ProcessLive.FormComponent,
        [
          title: "Processes",
          type: :process,
          parent_type: :version,
          struct: %Process{},
          objects: @version.processes,
          return_to: Routes.process_index_path(@socket, :index),
          id: "version-" <> Integer.to_string(@version.id) <> "-processes",
          parent: @version,
          select_lists: %{
            available_elements: @available_elements,
            available_step_types: @available_step_types,
            available_pages: @version.pages,
            available_processes: @version.processes
          }
        ]
      ) %>
      <%= live_group(@socket, PageLive.Header, PageLive.ShowComponent, PageLive.FormComponent,
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
            available_step_types: @available_step_types,
            available_annotation_types: @available_annotation_types
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
      |> assign(:available_annotation_types, annotation_types())
      |> assign(:available_elements, elements())

    {:ok, socket}
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:version, None)

    {:ok, socket}
  end

  #TODO: Needs to be fixed badly

  defp processes do
    Automation.list_processes()
  end

  defp elements do
    Web.list_elements()
  end

  defp step_types do
    Automation.list_step_types()
  end

  defp annotation_types do
    Web.list_annotation_types()
  end

  defp available_content() do
    Documents.list_content()
  end
end

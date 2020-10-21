defmodule UserDocsWeb.VersionLive.ShowComponent do
  use UserDocsWeb, :live_component

  require Logger

  alias UserDocsWeb.State

  alias UserDocs.Web.Page

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

      <%= if Ecto.assoc_loaded?(@version.processes) do %>
        <%= live_group(@socket, ProcessLive.Header, ProcessLive.ShowComponent, ProcessLive.FormComponent,
          [
            title: "Processes",
            type: :process,
            parent_type: :version,
            struct: %Process{},
            objects: @version.processes,
            return_to: Routes.process_index_path(@socket, :index),
            id: "version-#{@version.id}-processes",
            parent: @version,
            current_user: @current_user,
            current_team: @current_team,
            current_version: @current_version,
            select_lists: %{
              available_elements: @select_lists.available_elements,
              available_versions: @available_versions,
              available_step_types: @select_lists.available_step_types,
              available_pages: @version.pages,
              available_processes: @version.processes,
              available_annotation_types: @select_lists.available_annotation_types,
              available_content_versions: @select_lists.available_content_versions,
              available_content: @select_lists.available_content,
              language_codes: @select_lists.language_codes,
              strategies: @select_lists.strategies
            }
          ]
        ) %>
      <%= end %>
      <%= if Ecto.assoc_loaded?(@version.pages) do %>
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
            current_user: @current_user,
            current_team: @current_team,
            current_version: @current_version,
            select_lists: %{
              available_elements: @select_lists.available_elements,
              available_versions: @available_versions,
              available_pages: @version.pages,
              available_step_types: @select_lists.available_step_types,
              available_annotation_types: @select_lists.available_annotation_types,
              available_content_versions: @select_lists.available_content_versions,
              available_content: @select_lists.available_content,
              language_codes: @select_lists.language_codes,
              strategies: @select_lists.strategies
            }
          ]
        ) %>
      <%= end %>
    </div>
    """
  end


  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    {:ok, socket}
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:version, None)

    {:ok, socket}
  end
end

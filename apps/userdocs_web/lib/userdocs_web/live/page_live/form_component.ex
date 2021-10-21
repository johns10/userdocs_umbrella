defmodule UserDocsWeb.PageLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Web
  alias UserDocs.Pages.Page
  alias UserDocs.Projects.Project

  alias UserDocsWeb.LiveHelpers
  alias UserDocsWeb.Layout
  alias UserDocsWeb.ID

  @impl true
  def render(assigns) do
    ~L"""
      <%= form = form_for @changeset, "#",
        id: "page-form",
        phx_target: @myself.cid,
        phx_change: "validate",
        phx_submit: "save",
        class: "form-horizontal" %>

        <h2 class="text-xl font-bold"><%= @title %></h4>

        <%= render_fields(assigns, form) %>

        <%= submit "Save", phx_disable_with: "Saving...", class: "btn btn-primary mt-4" %>
      </form>
    """
  end

  def render_fields(assigns, form, _opts \\ []) do
    ~L"""
      <div class="grid grid-cols-3 gap-2">
        <div class="form-control">
          <%= label form, :project_id, class: "label" %>
          <%= select form, :project_id, @select_lists.projects,
            class: "select select-sm select-bordered",
            selected: @current_project.id || "" %>
          <%= error_tag form, :project_id %>
        </div>
        <div class="form-control col-span-2">
          <%= label form, :name, class: "label" %>
          <%= text_input form, :name, type: "text", class: "input input-sm input-bordered" %>
          <%= error_tag form, :name %>
        </div>
      </div>
      <%= if form_url_starts_with_slash(form) do %>
        <div class="form-control">
          <%= label form, :url, class: "label" %>
          <div class="flex">
            <div class="rounded-r-none rounded-l-lg flex-shrink bg-grey bg-base-300 px-2 py-1">
              <%= url_prefix(form.data.project, @current_user) %>
            </div>
            <%= text_input form, :url, type: "text", class: "input input-sm input-bordered rounded-l-none flex-grow" %>
          </div>
          <%= error_tag form, :url %>
        </div>
      <% else %>
      <div class="form-control">
        <%= label form, :url, class: "label" %>
        <%= text_input form, :url, type: "text", class: "input input-sm input-bordered flex-grow" %>
        <%= error_tag form, :url %>
      </div>
      <% end %>
    """
  end

  @impl true
  def update(%{page: page} = assigns, socket) do
    changeset = Web.change_page(page)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"page" => page_params}, socket) do
    changeset =
      socket.assigns.page
      |> Web.change_page(page_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"page" => page_params}, socket) do
    save_page(socket, socket.assigns.action, page_params)
  end

  defp save_page(socket, :edit, page_params) do
    case Web.update_page(socket.assigns.page, page_params) do
      {:ok, _page} ->
        {:noreply,
         socket
         |> put_flash(:info, "Page updated successfully")
         |> LiveHelpers.maybe_push_redirect()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_page(socket, :new, page_params) do
    case Web.create_page(page_params) do
      {:ok, _page} ->
        {:noreply,
         socket
         |> put_flash(:info, "Page created successfully")
         |> LiveHelpers.maybe_push_redirect()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def field_ids(page = %Page{}) do
    %{}
    |> Map.put(:order, ID.form_field(page, :order))
    |> Map.put(:name, ID.form_field(page, :name))
    |> Map.put(:url, ID.form_field(page, :url))
  end
  def field_ids(_) do
    %{}
    |> Map.put(:order, "")
    |> Map.put(:name, "")
    |> Map.put(:url, "")
  end

  def form_url_starts_with_slash(%{source: source}) do
    case Ecto.Changeset.get_field(source, :url, "") do
      nil -> false
      url -> String.at(url, 0) == "/"
    end
  end

  def url_prefix(project, user) do
    if Kernel.is_struct(project, Project) do
      if project.id in Enum.map(user.overrides, fn(o) -> o.project_id end) do
        Enum.filter(user.overrides, fn(o) -> o.project_id == project.id end)
        |> Enum.at(0)
        |> Map.get(:url)
      else
        project.base_url
      end
    end
  end
end

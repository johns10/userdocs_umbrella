defmodule ProcessAdministratorWeb.PageLive.FormComponent do
  use ProcessAdministratorWeb, :live_component

  alias UserDocs.Web

  alias ProcessAdministratorWeb.LiveHelpers
  alias ProcessAdministratorWeb.DomainHelpers
  alias ProcessAdministratorWeb.Layout

  def render(assigns) do
    ~L"""
      <%= form = form_for @changeset, "#",
        id: @id,
        phx_target: @myself.cid,
        phx_change: "validate",
        phx_submit: "save",
        class: "form-horizontal" %>

        <h4><%= @title %></h4>

        <%= render_fields(assigns, form) %>

        <%= submit "Save", phx_disable_with: "Saving...", class: "button is-link" %>
      </form>
    """
  end

  def render_fields(assigns, form, opts \\ []) do
    ~L"""
      <%= Layout.select_input(form, :version_id, @select_lists.versions, [
        selected: @parent_id || "",
        id: @field_ids.version_id || ""
      ], "control") %>

      <%= Layout.number_input(form, :order, [
        id: @field_ids.order || ""
      ], "control") %>

      <%= Layout.text_input(form, [
        field_name: :name,
        id: @field_ids.name
      ]) %>

      <%= Layout.text_input(form, [
        field_name: :url,
        id: @field_ids.url
      ]) %>
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
end

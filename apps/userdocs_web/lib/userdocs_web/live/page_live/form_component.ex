defmodule UserDocsWeb.PageLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Web

  alias UserDocsWeb.LiveHelpers
  alias UserDocsWeb.Layout
  alias UserDocsWeb.ID

  @impl true
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
      <div class="field is-grouped">
        <%= Layout.select_input(form, :version_id, @select_lists.versions, [
          # TODO: Still a little funky
          selected: @current_version.id || "",
          id: opts[:prefix] <> "page-id"
        ], "control") %>
        <%= Layout.text_input(form, [ field_name: :name ], "control is-expanded") %>
      </div>
      <%= if String.at(form.data.url, 0) == "/" do %>
        <div class="field">
          <%= label form, :url, class: "label" %>
          <p class="control is-expanded">
            <div class="field has-addons">
              <p class="control">
                <a class="button is-static">
                  <%= if form.data.project.id in Enum.map(@current_user.overrides, fn(o) -> o.project_id end) do %>
                    <%= Enum.filter(@current_user.overrides, fn(o) -> o.project_id == form.data.project.id end) |> Enum.at(0) |> Map.get(:url) %>
                  <% else %>
                    <%= form.data.project.base_url %>
                  <% end %>
                </a>
              </p>
              <%= text_input form, :url, [ class: "input", type: "text" ] %>
            </div>
            <%= error_tag form, :selector %>
          </p>
        </div>
      <% else %>
        <%= Layout.text_input(form, [
          field_name: :url,
          id: opts[:prefix] <> "url-input"
        ], "control is-expanded") %>
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

  def field_ids(page = %Web.Page{}) do
    %{}
    |> Map.put(:version_id, ID.form_field(page, :version_id))
    |> Map.put(:order, ID.form_field(page, :order))
    |> Map.put(:name, ID.form_field(page, :name))
    |> Map.put(:url, ID.form_field(page, :url))
  end
  def field_ids(_) do
    %{}
    |> Map.put(:version_id, "")
    |> Map.put(:order, "")
    |> Map.put(:name, "")
    |> Map.put(:url, "")
  end
end

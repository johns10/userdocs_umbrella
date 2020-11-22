defmodule ProcessAdministratorWeb.ContentVersionLive.FormComponent do
  use ProcessAdministratorWeb, :live_component

  require Logger

  alias UserDocs.Documents

  alias ProcessAdministratorWeb.ID
  alias UserDocsWeb.Layout

  def render_fields(assigns) do
    ~L"""
      <h2><%= @title %></h2>
      <%= @action %>
      <%= f = form_for @changeset, "#",
        id: "content_version-form",
        phx_target: @myself,
        phx_change: "validate",
        phx_submit: "save" %>

        <%= ProcessAdministratorWeb.ContentVersionLive.FormComponent.render_fields(assigns, f) %>

        <%= submit "Save", phx_disable_with: "Saving..." %>
      </form>

    """
  end

  def render_fields(assigns, form, prefix \\ "") do
    ~L"""
      <%= hidden_input form, :content_id %>
      <%= hidden_input form, :version_id %>
      <%= hidden_input form, :temp_id %>

      <div class="field is-grouped">

        <%= Layout.select_input(form, :language_code_id, @select_lists.language_codes, [
          value: form.data.language_code_id,
          id: ID.form_field(form.data, :language_code_id, prefix)
        ], "control") %>

        <%= Layout.text_input(form, :name, [
          id: ID.form_field(form.data, :name, prefix)
        ], "control is-expanded") %>

      </div>

      <div class="field">
        <%= label form, :body %>
        <div class="control">
          <%= textarea form, :body,
            class: "textarea" %>
        </div>
        <%= error_tag form, :body %>
      </div>

      <div class="field">
        <div class="control">
          <%=
            temp_id = Map.get(form.source.changes, :temp_id, form.data.temp_id)
            if is_nil(temp_id) do %>
            <a
              class="button"
              phx-click="delete-content-version"
              phx-value-id= <%= form.data.id %>
              phx-target="<%= @myself.cid %>"
            >
              &times Delete Existing
            </a>
          <% else %>
            <a
              class="button"
              phx-click="remove-content-version"
              phx-value-remove="<%= temp_id %>"
              phx-target="<%= @myself.cid %>"
            >
              &times Delete
            </a>
          <% end %>
        </div>
      </div>
    """
  end

  @impl true
  @spec update(
          %{content_version: UserDocs.Documents.ContentVersion.t()},
          Phoenix.LiveView.Socket.t()
        ) :: {:ok, Phoenix.LiveView.Socket.t()}
  def update(%{content_version: content_version} = assigns, socket) do
    changeset = Documents.change_content_version(content_version)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"content_version" => content_version_params}, socket) do
    changeset =
      socket.assigns.content_version
      |> Documents.change_content_version(content_version_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"content_version" => content_version_params}, socket) do
    save_content_version(socket, socket.assigns.action, content_version_params)
  end

  defp save_content_version(socket, :edit, content_version_params) do
    case Documents.update_content_version(socket.assigns.content_version, content_version_params) do
      {:ok, _content_version} ->
        {:noreply,
         socket
         |> put_flash(:info, "Content version updated successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_content_version(socket, :new, content_version_params) do
    case Documents.create_content_version(content_version_params) do
      {:ok, _content_version} ->
        {:noreply,
         socket
         |> put_flash(:info, "Content version created successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

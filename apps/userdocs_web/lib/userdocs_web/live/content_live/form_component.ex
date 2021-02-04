defmodule UserDocsWeb.ContentLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Documents
  alias UserDocs.Documents.ContentVersion

  alias UserDocsWeb.Layout

  alias UserDocsWeb.ContentVersionLive.FormComponent, as: ContentVersionForm

  @impl true
  def render(assigns) do
    ~L"""
      <%= form = form_for @changeset, "#",
        id: "content-form",
        phx_target: @myself.cid,
        phx_change: "validate",
        phx_submit: "save" %>

        <%= render_fields(assigns, form) %>

        <div class="control">
          <%= submit "Save", phx_disable_with: "Saving...", class: "button is-link" %>
          <%= if @action == :edit do %>
            <%= link "Delete",
              to: "#",
              phx_click: "delete",
              phx_value_id: @changeset.data.id,
              data: [confirm: "Are you sure?"],
              class: "button is-danger is-link"
            %>
          <% end %>
        </div>

      </form>
    """
  end

  def render_fields(assigns, form, _prefix \\ "") do
    ~L"""
      <div class="field is-grouped">
        <%= Layout.select_input(form, :team_id, @select_lists.teams, [
            value: form.data.team_id || @team_id
          ], "control") %>

        <%= Layout.text_input(form, :name, [
          ], "control is-expanded") %>
      </div>
      <%= inputs_for form, :content_versions, fn fcv -> %>

        <%= ContentVersionForm.render_fields(assigns, fcv, "test") %>

      <% end %>

      <a class="button" href="#" phx-click="add-content-version"
        phx-target="<%= @myself.cid %>">
        Add a content translation
      </a>
    """
  end

  @impl true
  def update(%{content: content} = assigns, socket) do
    changeset = Documents.change_content(content)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"content" => content_params}, socket) do
    changeset =
      socket.assigns.content
      |> Documents.change_content(content_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end
  def handle_event("save", %{"content" => content_params}, socket) do
    save_content(socket, socket.assigns.action, content_params)
  end
  def handle_event("add-content-version", _, socket) do
    existing_variants =
      Ecto.Changeset.get_field(socket.assigns.changeset, :content_versions)

    content_version = %ContentVersion{
      temp_id: UserDocs.ID.temp_id(),
      content_id: socket.assigns.content.id,
      version_id: socket.assigns.version_id,
      body: ""
    }

    content_versions =
      existing_variants
      |> Enum.concat([ Documents.change_content_version(content_version) ])

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:content_versions, content_versions)

    {:noreply, assign(socket, changeset: changeset)}
  end
  def handle_event("remove-content-version", %{"remove" => remove_id}, socket) do
    content_versions =
      Ecto.Changeset.get_change(socket.assigns.changeset, :content_versions)
      |> Enum.reject(fn %{data: variant} -> variant.temp_id == remove_id end)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:content_versions, content_versions)

    {:noreply, assign(socket, changeset: changeset)}
  end
  def handle_event("delete-content-version", %{"id" => id}, socket) do
    content_version = Documents.get_content_version!(id)
    {:ok, _} = Documents.delete_content_version(content_version)
    {:noreply, socket}
  end

  defp save_content(socket, :edit, content_params) do
    case Documents.update_content(socket.assigns.content, content_params) do
      {:ok, content} ->
        message = %{ objects: content.content_versions }
        UserDocsWeb.Endpoint.broadcast(socket.assigns.channel, "update", content)
        UserDocsWeb.Endpoint.broadcast(socket.assigns.channel, "update", message)
        {
          :noreply,
          socket
          |> assign(:content, content)
          |> assign(:changeset, Documents.change_content(content))
          |> put_flash(:info, "Content updated successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_content(socket, :new, content_params) do
    case Documents.create_content(content_params) do
      {:ok, content} ->
        message = %{ objects: content.content_versions }
        UserDocsWeb.Endpoint.broadcast(socket.assigns.channel, "create", content)
        UserDocsWeb.Endpoint.broadcast(socket.assigns.channel, "update", message)
        send(self(), :close_modal)
        {
          :noreply,
          socket
          |> put_flash(:info, "Content created successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def is_expanded?(false), do: " is-hidden"
  def is_expanded?(true), do: ""
end

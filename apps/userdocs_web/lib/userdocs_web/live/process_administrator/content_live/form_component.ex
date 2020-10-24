defmodule UserDocsWeb.ProcessAdministratorLive.ContentLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.ProcessAdministratorLive.Layout
  alias UserDocsWeb.ProcessAdministratorLive.ID
  alias UserDocs.Documents

  alias UserDocsWeb.ProcessAdministratorLive.ContentVersionLive.FormComponent

  @impl true
  def render(assigns) do
    ~L"""
      <%= form = form_for @changeset, "#",
        id: "content-form",
        phx_target: @myself.cid,
        phx_change: "validate",
        phx_submit: "save" %>

        <%= render_fields(assigns, form) %>

        <%= submit "Save", phx_disable_with: "Saving..." %>z
      </form>
    """
  end

  def render_fields(assigns, form, prefix \\ "") do
    ~L"""
      <div class="field is-grouped">
        <%= Layout.select_input(form, :team_id, @select_lists.teams_select, [
            value: form.data.team_id || @parent_id
          ], "control") %>

        <%= Layout.text_input(form, :name, [
            id: ID.form_field(form.data, :name, prefix),
          ], "control is-expanded") %>

      </div>

      <%= if false do %>
        <section class="card">
          <header class="card-header">
            <p class="card-header-title" style="margin-bottom:0px;">
              Content Versions
            </p>
            <a
              class="card-header-icon"
              phx-click="expand-annotation-content"
              phx-target="<%= @myself.cid %>"
              aria-label="expand">
              <span class="icon" >
                <i class="fa fa-angle-down" aria-hidden="true"></i>
              </span>
            </a>
          </header>
          <div class="card-content <%= is_expanded?(@nested_annotation_content_expanded) %>">
            <div class="content">

              <%= inputs_for form, :content_versions, fn fcv -> %>

                <%= FormComponent.render_fields(assigns, fcv,
                  prefix <> ID.prefix(form.data)) %>

              <% end %>

              <a class="button" href="#" phx-click="add-content-version"
                phx-target="<%= @myself.cid %>">
                Add a content translation
              </a>
            </div>
          </div>
        </section>
      <% end %>
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

  defp save_content(socket, :edit, content_params) do
    case Documents.update_content(socket.assigns.content, content_params) do
      {:ok, _content} ->
        {:noreply,
         socket
         |> put_flash(:info, "Content updated successfully")
         # |> push_redirect(to: socket.assigns.return_to)
         |> push_patch(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_content(socket, :new, content_params) do
    case Documents.create_content(content_params) do
      {:ok, _content} ->
        {:noreply,
         socket
         |> put_flash(:info, "Content created successfully")
         # |> push_redirect(to: socket.assigns.return_to)
         |> push_patch(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def is_expanded?(false), do: " is-hidden"
  def is_expanded?(true), do: ""
end

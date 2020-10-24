defmodule ProcessAdministratorWeb.ElementLive.FormComponent do
  use UserDocsWeb, :live_component

  require Logger

  alias UserDocs.Web

  alias ProcessAdministratorWeb.Layout
  alias ProcessAdministratorWeb.ID

  def render(assigns) do
    ~L"""
      <%= form = form_for @changeset, "#",
        id: @id,
        phx_target: @myself.cid,
        phx_change: "validate",
        phx_submit: "save" %>
        <%= render_fields(assigns, form) %>
        <%= submit "Save", phx_disable_with: "Saving...", class: "button is-link" %>
      </form>
    """
  end

  def render_fields(assigns, form, prefix \\ "") do
    ~L"""
      <div class="field is-grouped">

        <%= Layout.select_input(form, :page_id, @select_lists.pages_select, [
          placeholder: @parent_id || "",
          id: ID.form_field(form.data, :page_id, prefix),
        ], "control") %>

        <%= Layout.text_input(form, :name, [
          id: ID.form_field(form.data, :name, prefix)
        ], "control") %>

        <%= Layout.number_input(form, :order, [
          id: ID.form_field(form.data, :order, prefix)
        ]) %>

      </div>
      <div class="field">
        <%= label form, :selector, class: "label" %>
        <p class="control is-expanded">
          <div class="field has-addons">

            <%= Layout.select_input(form, :strategy_id, @select_lists.strategies, [
                id: ID.form_field(form.data, :strategy_id, prefix), label: false
              ], "control") %>

            <%= Layout.text_input(form, :selector, [
                label: false,
                id: ID.form_field(form.data, :selector, prefix)
              ], "control is-expanded") %>

            <div class="control">
              <button
                class="button"
                type="button"
                id="<%= ID.strategy_field(form.data.page_id, form.data.id) %>"
                selector="<%= ID.form_field(form.data, :strategy_id, prefix) %>"
                strategy="<%= ID.form_field(form.data, :selector, prefix) %>"
                phx-hook="CopySelector"
              >
                <span class="icon" >
                  <i
                    class="fa fa-arrow-left"
                    aria-hidden="true"
                  ></i>
                </span>
              </span>
            </div>
            <!-- TODO validate that @changeset.data.selector works here -->
            <p class="control">
              <button
                type="button"
                class="button"
                phx-target="<%= @myself.cid %>"
                phx-value-element-id="<%= form.data.id %>"
                phx-value-selector="test"
                phx-value-strategy="css"
                phx-click="test_selector"
              >
                <span class="icon" >
                  <i class="fa fa-cloud-upload"
                    aria-hidden="true"
                  ></i>
                </span>
              </span>
            </p>
          </div>
          <%= error_tag form, :selector %>
        </p>
      </div>
    """
  end

  @impl true
  def update(%{element: element} = assigns, socket) do
    changeset = Web.change_element(element)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"element" => element_params}, socket) do
    changeset =
      socket.assigns.element
      |> Web.change_element(element_params)
      |> Map.put(:action, :validate)

    { :noreply, assign(socket, :changeset, changeset) }
  end

  def handle_event("save", %{"element" => element_params}, socket) do
    save_element(socket, socket.assigns.action, element_params)
  end

  defp save_element(socket, :edit, element_params) do
    case Web.update_element(socket.assigns.element, element_params) do
      {:ok, _element} ->
        {:noreply,
         socket
         |> put_flash(:info, "Element updated successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_element(socket, :new, element_params) do
    case Web.create_element(element_params) do
      {:ok, _element} ->
        {:noreply,
         socket
         |> put_flash(:info, "Element created successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

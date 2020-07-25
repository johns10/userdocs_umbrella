defmodule UserDocsWeb.ElementLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Web

  alias UserDocsWeb.LiveHelpers
  alias UserDocsWeb.DomainHelpers
  alias UserDocsWeb.Layout

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:copied_selector, None)

    {:ok, socket}
  end

  @impl true
  def update(%{element: element} = assigns, socket) do
    changeset = Web.change_element(element)
    maybe_parent_id = DomainHelpers.maybe_parent_id(assigns, :page_id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:read_only, LiveHelpers.read_only?(assigns))
     |> assign(:maybe_action, LiveHelpers.maybe_action(assigns))
     |> assign(:maybe_parent_id, maybe_parent_id)
     |> assign(:selector_field_id, selector_field_id(assigns, changeset))
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"element" => element_params}, socket) do
    changeset =
      socket.assigns.element
      |> Web.change_element(element_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
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
         |> LiveHelpers.maybe_push_redirect()}

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
         |> LiveHelpers.maybe_push_redirect()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp selector_field_id(assigns, changeset) do
    "page-"
    <> Integer.to_string(DomainHelpers.maybe_parent_id(assigns, :page_id))
    <> "-element-"
    <> LiveHelpers.maybe_value(changeset.data.id, "new")
    <> "-form-selector-field"
  end
end

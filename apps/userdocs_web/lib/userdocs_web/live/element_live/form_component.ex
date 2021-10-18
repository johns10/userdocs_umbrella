defmodule UserDocsWeb.ElementLive.FormComponent do
  use UserDocsWeb, :live_component

  require Logger

  alias UserDocs.Web

  alias UserDocsWeb.Layout
  alias UserDocsWeb.ID

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
        {
          :noreply,
          socket
          |> put_flash(:info, "Element updated successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_element(socket, :new, element_params) do
    case Web.create_element(element_params) do
      {:ok, _element} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Element created successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def field_ids(element = %Web.Element{}) do
    %{}
    |> Map.put(:page_id, ID.form_field(element, :page_id))
    |> Map.put(:order, ID.form_field(element, :order))
    |> Map.put(:name, ID.form_field(element, :name))
    |> Map.put(:strategy_id, ID.form_field(element, :strategy_id))
    |> Map.put(:selector, ID.form_field(element, :selector))
  end
  def field_ids(_) do
    temp_id = UUID.uuid4()
    %{}
    |> Map.put(:page_id, "")
    |> Map.put(:order, "")
    |> Map.put(:name, "")
    |> Map.put(:strategy_id, "element-" <> temp_id <> "-strategy-id")
    |> Map.put(:selector, "element-" <> temp_id <> "-selector")
  end
end

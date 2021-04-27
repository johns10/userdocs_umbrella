defmodule UserDocsWeb.ProcessLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Automation
  alias UserDocsWeb.Layout
  alias UserDocsWeb.ID

  @impl true
  def update(%{process: process} = assigns, socket) do
    changeset = Automation.change_process(process)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:version_field_id, ID.form_field(process, :version_id))
      |> assign(:order_field_id, ID.form_field(process, :order))
      |> assign(:name_field_id, ID.form_field(process, :name))
    }
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    process = Automation.get_process!(String.to_integer(id))
    {:ok, deleted_process } = Automation.delete_process(process)
    send(self(), { :broadcast, "delete", deleted_process })
    {:noreply, socket}
  end
  def handle_event("validate", %{"process" => process_params}, socket) do
    changeset =
      socket.assigns.process
      |> Automation.change_process(process_params)
      |> Map.put(:action, :validate)

    {
      :noreply,
      assign(socket, :changeset, changeset)
    }
  end

  def handle_event("save", %{"process" => process_params}, socket) do
    save_process(socket, socket.assigns.action, process_params)
  end

  defp save_process(socket, :edit, process_params) do
    case Automation.update_process(socket.assigns.process, process_params) do
      {:ok, process} ->
        send(self(), { :broadcast, "update", process })
        {
          :noreply,
          socket
          |> put_flash(:info, "Process updated successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_process(socket, :new, process_params) do
    case Automation.create_process(process_params) do
      {:ok, process} ->
        send(self(), { :broadcast, "create", process })
        {
          :noreply,
          socket
          |> put_flash(:info, "Process created successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

defmodule ProcessAdministratorWeb.ProcessLive.FormComponent do
  use ProcessAdministratorWeb, :live_component

  alias UserDocs.Automation
  alias ProcessAdministratorWeb.Layout
  alias ProcessAdministratorWeb.ID

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
      {:ok, _process} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Process updated successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_process(socket, :new, process_params) do
    case Automation.create_process(process_params) do
      {:ok, _process} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Process created successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

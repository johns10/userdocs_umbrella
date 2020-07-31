defmodule UserDocsWeb.ProcessLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Automation
  alias UserDocsWeb.DomainHelpers
  alias UserDocsWeb.LiveHelpers
  alias UserDocsWeb.Layout

  @impl true
  def update(%{process: process} = assigns, socket) do
    changeset = Automation.change_process(process)
    maybe_parent_id = DomainHelpers.maybe_parent_id(
      assigns, :page_id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:read_only, LiveHelpers.read_only?(assigns))
     |> assign(:maybe_action, LiveHelpers.maybe_action(assigns))
     |> assign(:maybe_parent_id, maybe_parent_id)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"process" => process_params}, socket) do
    changeset =
      socket.assigns.process
      |> Automation.change_process(process_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"process" => process_params}, socket) do
    save_process(socket, socket.assigns.action, process_params)
  end

  defp save_process(socket, :edit, process_params) do
    case Automation.update_process(socket.assigns.process, process_params) do
      {:ok, _process} ->
        {:noreply,
         socket
         |> put_flash(:info, "Process updated successfully")
         |> LiveHelpers.maybe_push_redirect()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_process(socket, :new, process_params) do
    case Automation.create_process(process_params) do
      {:ok, _process} ->
        {:noreply,
         socket
         |> put_flash(:info, "Process created successfully")
         |> LiveHelpers.maybe_push_redirect()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

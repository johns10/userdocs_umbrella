defmodule UserDocsWeb.ProcessesLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Projects
  alias UserDocs.Web
  alias UserDocs.Automation
  alias UserDocsWeb.DomainHelpers

  @impl true
  def update(%{process: process} = assigns, socket) do
    changeset = Automation.change_process(process)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:available_versions, available_versions())
     |> assign(:available_pages, available_pages())
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
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_process(socket, :new, process_params) do
    case Automation.create_process(process_params) do
      {:ok, process} ->
        IO.puts("Saving Process")

        check_nil(process_params["pages"])
        |> Enum.map(fn(page_id) -> %{process_id: process.id, page_id: String.to_integer(page_id)} end)
        |> Enum.each(fn(p) -> Automation.create_page_process(p) end)

        check_nil(process_params["versions"])
        |> Enum.map(fn(version_id) -> %{process_id: process.id, version_id: String.to_integer(version_id)} end)
        |> Enum.each(fn(v) -> Automation.create_version_process(v) end)

        {:noreply,
         socket
         |> put_flash(:info, "Process created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp available_versions do
    Projects.list_versions()
  end

  defp available_pages do
    Web.list_pages()
  end

  defp check_nil(items), do: items || []
end

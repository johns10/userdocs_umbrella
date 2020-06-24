defmodule UserDocsWeb.ProcessLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Projects
  alias UserDocs.Web
  alias UserDocs.Automation
  alias UserDocsWeb.DomainHelpers
  alias UserDocsWeb.LiveHelpers

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:action, None)
      |> assign(:title, None)
      |> assign(:parent_component, None)
    {:ok, socket}
  end

  @impl true
  def update(%{empty_changeset: process} = assigns, socket) do
    assigns =
      assigns
      |> Map.put(:process, process)
      |> Map.delete(:empty_changeset)

    update(assigns, socket)
  end
  def update(%{process: process} = assigns, socket) do
    changeset = Automation.change_process(process)
    IO.inspect(assigns)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:title, assigns.opts[:title])
     |> assign(:action, assigns.opts[:action])
     |> assign(:parent_component, assigns.opts[:parent_component])
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
         |> LiveHelpers.maybe_push_redirect()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_process(socket, :new, process_params) do
    case Automation.create_process(process_params) do
      {:ok, process} ->
        #Left to crib from later
        """
        check_nil(process_params["pages"])
        |> Enum.map(fn(page_id) -> %{process_id: process.id, page_id: String.to_integer(page_id)} end)
        |> Enum.each(fn(p) -> Automation.create_page_process(p) end)
        """
        {:ok, _version_process } =
          maybe_add_version_process(process.id, process_params["versions"])

        {:ok, _page_process } =
          maybe_add_page_process(process.id, process_params["pages"])

        {:noreply,
         socket
         |> put_flash(:info, "Process created successfully")
         |> LiveHelpers.maybe_push_redirect()}

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

  defp maybe_add_page_process(_, "Elixir.None"), do: { :ok, None }
  defp maybe_add_page_process(process_id, page_id) do
    %{ process_id: process_id, page_id: String.to_integer(page_id) }
    |> Automation.create_page_process
  end

  defp maybe_add_version_process(_, "Elixir.None"), do: { :ok, None }
  defp maybe_add_version_process(process_id, version_id) do
    %{ process_id: process_id, version_id: String.to_integer(version_id) }
    |> Automation.create_version_process()
  end
end

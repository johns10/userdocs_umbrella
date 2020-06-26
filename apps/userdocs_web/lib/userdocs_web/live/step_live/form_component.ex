defmodule UserDocsWeb.StepLive.FormComponent do
  use UserDocsWeb, :live_component
  alias UserDocsWeb.DomainHelpers

  alias UserDocs.Automation
  alias UserDocs.Web

  @impl true
  def update(%{step: step} = assigns, socket) do
    changeset = Automation.change_step(step)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:available_processes, available_processes())
     |> assign(:available_elements, available_elements(step))
     |> assign(:step_types, step_types())
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"step" => step_params}, socket) do
    changeset =
      socket.assigns.step
      |> Automation.change_step(step_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"step" => step_params}, socket) do
    save_step(socket, socket.assigns.action, step_params)
  end

  defp save_step(socket, :edit, step_params) do
    case Automation.update_step(socket.assigns.step, step_params) do
      {:ok, _step} ->
        {:noreply,
         socket
         |> put_flash(:info, "Step updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_step(socket, :new, step_params) do
    case Automation.create_step(step_params) do
      {:ok, _step} ->
        {:noreply,
         socket
         |> put_flash(:info, "Step created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp available_processes do
    Automation.list_processes()
  end

  defp available_elements(step) do
    IO.puts("Getting available elements")
    process = Automation.get_process!(
      step.process_id,
      %{pages: true, versions: true}
    )
    versions_or_pages_elements(process.versions, process.pages)
  end

  defp versions_or_pages_elements([ version | _ ], []) do
    IO.puts("Getting version elements")
    Web.list_elements(%{}, %{version_id: version.id})
  end
  defp versions_or_pages_elements([], [ page | _ ]) do
    IO.puts("Getting page elements")
    Web.list_elements(%{}, %{page_id: page.id})
  end

  defp step_types do
    Automation.list_step_types()
  end
end

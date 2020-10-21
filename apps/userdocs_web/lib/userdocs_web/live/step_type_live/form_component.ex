defmodule UserDocsWeb.StepTypeLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Automation

  @impl true
  def update(%{step_type: step_type} = assigns, socket) do
    changeset = Automation.change_step_type(step_type)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"step_type" => step_type_params}, socket) do
    changeset =
      socket.assigns.step_type
      |> Automation.change_step_type(step_type_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"step_type" => step_type_params}, socket) do
    save_step_type(socket, socket.assigns.action, step_type_params)
  end

  defp save_step_type(socket, :edit, step_type_params) do
    case Automation.update_step_type(socket.assigns.step_type, step_type_params) do
      {:ok, _step_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Step type updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_step_type(socket, :new, step_type_params) do
    case Automation.create_step_type(step_type_params) do
      {:ok, _step_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Step type created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

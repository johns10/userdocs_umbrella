defmodule UserDocsWeb.StepLive.FormComponent do
  use UserDocsWeb, :live_component
  alias UserDocsWeb.DomainHelpers

  alias UserDocs.Automation

  @impl true
  def update(%{step: step} = assigns, socket) do
    changeset = Automation.change_step(step)

    {:ok,
     socket
     |> assign(assigns)
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
end

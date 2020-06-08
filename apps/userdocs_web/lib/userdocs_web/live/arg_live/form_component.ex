defmodule UserDocsWeb.ArgLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Automation

  @impl true
  def update(%{arg: arg} = assigns, socket) do
    changeset = Automation.change_arg(arg)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"arg" => arg_params}, socket) do
    changeset =
      socket.assigns.arg
      |> Automation.change_arg(arg_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"arg" => arg_params}, socket) do
    save_arg(socket, socket.assigns.action, arg_params)
  end

  defp save_arg(socket, :edit, arg_params) do
    case Automation.update_arg(socket.assigns.arg, arg_params) do
      {:ok, _arg} ->
        {:noreply,
         socket
         |> put_flash(:info, "Arg updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_arg(socket, :new, arg_params) do
    case Automation.create_arg(arg_params) do
      {:ok, _arg} ->
        {:noreply,
         socket
         |> put_flash(:info, "Arg created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

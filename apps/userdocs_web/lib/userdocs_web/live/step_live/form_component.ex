defmodule UserDocsWeb.StepLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.LiveHelpers
  alias UserDocsWeb.DomainHelpers

  alias UserDocs.Automation
  alias UserDocs.Web

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:enabled_fields, [])

    {:ok, socket}
  end

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
    socket = enabled_fields(step_params["step_type_id"], socket)

    changeset =
      socket.assigns.step
      |> Automation.change_step(step_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"step" => step_params}, socket) do
    save_step(socket, socket.assigns.action, step_params)
  end

  defp enabled_fields("Elixir.None", socket), do: socket
  defp enabled_fields(step_type_id, socket) do
    args = Enum.filter(
        socket.assigns.step_types,
        fn(x) -> x.id == String.to_integer(step_type_id) end
      )
      |> Enum.at(0)
      |> Map.get(:args)

    assign(socket, :enabled_fields, args)
  end

  defp save_step(socket, :edit, step_params) do
    case Automation.update_step(socket.assigns.step, step_params) do
      {:ok, _step} ->
        {:noreply,
         socket
         |> put_flash(:info, "Step updated successfully")
         |> LiveHelpers.maybe_push_redirect()}

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
         |> LiveHelpers.maybe_push_redirect()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

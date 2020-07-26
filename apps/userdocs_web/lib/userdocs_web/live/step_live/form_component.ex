defmodule UserDocsWeb.StepLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.LiveHelpers
  alias UserDocsWeb.DomainHelpers
  alias UserDocsWeb.Layout

  alias UserDocs.Automation

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:enabled_fields, [])
      |> assign(:url_mode, Null)

    {:ok, socket}
  end

  @impl true
  def update(%{step: step} = assigns, socket) do
    changeset = Automation.change_step(step)
    maybe_parent_id = DomainHelpers.maybe_parent_id(assigns, :page_id)
    enabled_fields =
      LiveHelpers.enabled_fields(assigns.select_lists.available_step_types,
        changeset.data.step_type_id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:enabled_fields, enabled_fields)
     |> assign(:read_only, LiveHelpers.read_only?(assigns))
     |> assign(:maybe_action, LiveHelpers.maybe_action(assigns))
     |> assign(:maybe_parent_id, maybe_parent_id)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"step" => step_params}, socket) do
    enabled_fields =
      LiveHelpers.enabled_fields(socket.assigns.select_lists.available_step_types,
        step_params["step_type_id"])

    changeset =
      socket.assigns.step
      |> Automation.change_step(step_params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:enabled_fields, enabled_fields)

    {:noreply, socket}
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

  def handle_event("toggle_url_mode", %{"arg" => arg}, socket) do
    IO.puts("Toggling URL Mode")
    IO.inspect(arg)
    {:noreply, assign(socket, :url_mode, String.to_atom(arg))}
  end
end

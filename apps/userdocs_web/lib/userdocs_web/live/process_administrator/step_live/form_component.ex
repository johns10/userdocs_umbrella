defmodule UserDocsWeb.ProcessAdministratorLive.StepLive.FormComponent do
  use UserDocsWeb, :live_component

  require Logger

  alias UserDocsWeb.ProcessAdministratorLive.LiveHelpers
  alias UserDocsWeb.ProcessAdministratorLive.Layout
  alias UserDocsWeb.ProcessAdministratorLive.AnnotationLive
  alias UserDocsWeb.ProcessAdministratorLive.ElementLive
  alias UserDocsWeb.ProcessAdministratorLive.ID

  alias UserDocs.Automation
  alias UserDocs.ChangeTracker
  alias UserDocs.Documents
  alias UserDocs.Documents.ContentVersion

  @impl true
  def update(%{step: step} = assigns, socket) do
    changeset = Automation.change_step(step)
    step_type_id =
      try do
        step.step_type_id
      rescue
        _ ->
          assigns.data.step_types
          |> Enum.at(0)
          |> Map.get(:id)
      end

    annotation_type_id =
      try do
        step.annotation.annotation_type_id
      rescue
        _ ->
          assigns.data.annotation_types
          |> Enum.at(0)
          |> Map.get(:id)
      end

    enabled_step_fields =
      UserDocsWeb.LiveHelpers.enabled_fields(
        assigns.data.step_types,
        step_type_id
      )

    enabled_annotation_fields =
      UserDocsWeb.LiveHelpers.enabled_fields(
        assigns.data.annotation_types,
        annotation_type_id
      )

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:current_object, step)
      |> assign(:enabled_step_fields, enabled_step_fields)
      |> assign(:enabled_annotation_fields, enabled_annotation_fields)
      |> assign(:auto_gen_name, "")
      |> assign(:nested_element_expanded, false)
      |> assign(:nested_annotation_expanded, false)
      |> assign(:nested_annotation_content_expanded, false)
    }
  end

  @impl true
  def handle_event("validate", %{"step" => step_params}, socket) do
    changeset =
      socket.assigns.step
      |> Automation.change_step(step_params)
      |> Map.put(:action, :validate)

    socket_changes = ChangeTracker.execute(socket.assigns, step_params, &Automation.change_step/2)

    {
      :noreply,
      socket
      |> assign(:changeset, changeset)
      |> LiveHelpers.apply_changes(socket_changes)
    }
  end

  @impl true
  def handle_event("save", %{"step" => step_params}, socket) do
    save_step(socket, socket.assigns.action, step_params)
  end

  @impl true
  def handle_event("expand-annotation", _, socket), do: {:noreply, expand(socket, :nested_annotation_expanded)}
  def handle_event("expand-element", _, socket), do: {:noreply, expand(socket, :nested_element_expanded)}
  def handle_event("expand-annotation-content", _, socket), do: {:noreply, expand(socket, :nested_annotation_content_expanded)}

  def handle_event("test_selector", %{ "element-id" => element_id }, socket) do
    element_id = String.to_integer(element_id)

    element = UserDocs.Web.get_element!(element_id, %{ strategy: true }, %{}, socket.assigns.data)


    test =
      socket.assigns.data.elements
      |> Enum.filter(fn(e) -> e.id == element_id end)
      |> Enum.at(0)

    payload =  %{
      type: "step",
      payload: %{
        process: %{
          steps: [
            %{
              id: 0,
              selector: element.selector,
              strategy: element.strategy,
              step_type: %{
                name: "Test Selector"
              }
            }
           ],
        },
        element_id: socket.assigns.id,
        status: "not_started",
        active_annotations: []
      }
    }

    {
      :noreply,
      socket
      |> push_event("test_selector", payload)
    }
  end

  @impl true
  def handle_event("delete-content-version", %{"id" => id}, socket) do
    content_version = Documents.get_content_version!(String.to_integer(id), %{}, %{}, socket.assigns.data)
    {:ok, _} = Documents.delete_content_version(content_version)

    {:noreply, socket}
  end

  defp save_step(socket, :edit, step_params) do
    IO.puts("Saving step in formzs")
    case Automation.update_step(socket.assigns.step, step_params) do
      {:ok, _step} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Step updated successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_step(socket, :new, step_params) do
    case Automation.create_step(step_params) do
      {:ok, _step} ->
        {:noreply,
         socket
         |> put_flash(:info, "Step created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def expand(socket, key) do
    socket
    |> assign(key, not Map.get(socket.assigns, key))
  end
end

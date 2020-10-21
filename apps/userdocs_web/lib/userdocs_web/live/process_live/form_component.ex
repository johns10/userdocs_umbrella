defmodule UserDocsWeb.ProcessLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Automation
  alias UserDocsWeb.LiveHelpers
  alias UserDocsWeb.Layout
  alias UserDocsWeb.Form

  @impl true
  def update(%{process: process} = assigns, socket) do
    changeset = Automation.change_process(process)

    opts = %{
      changeset: changeset,
      parent_id_field: :version_id,
      key: :available_versions,
      function: &UserDocs.Projects.list_versions/2,
      params: %{},
      filter: %{},
      assigns: assigns
    }

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:available_versions, Form.available_items(opts))
     |> assign(:parent_id, Form.parent_id(opts))
     |> assign(:read_only, LiveHelpers.read_only?(assigns))
     |> assign(:maybe_action, LiveHelpers.maybe_action(assigns))
     |> assign(:action, action(assigns))
     |> assign(:id, form_id(assigns, changeset))
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

  def action(assigns) do
    { :ok, action } =
      { :nok, :edit }
      |> maybe_action_from_assigns(assigns)

    action
  end

  def maybe_action_from_assigns({ :nok, action }, assigns) do
    try do
      { :ok, Map.get(assigns, :action) }
    rescue
      _ -> { :nok, action }
    end
  end

  def form_id(assigns, changeset) do
    form_id = Map.get(assigns, :id)
    action = Map.get(assigns, :action)

    { :ok, form_id } =
      { :nok, form_id }
      |> id_from_action(action)
      |> id_from_assigns_parent(assigns)
      |> id_from_changeset(changeset)

    form_id
  end

  def id_from_action({ :nok, _ }, :new), do: { :ok, "process-new-form"}
  def id_from_action(state, :edit), do: state
  def id_from_actiont({ :ok, form_id }, _), do: { :ok, form_id }

  def id_from_assigns_parent({ :nok, _ }, %{ parent: %{ id: parent_id }}) do
    { :ok, "process-#{parent_id}-form" }
  end
  def id_from_assigns_parent(state, %{ parent: %{ id: nil }}), do: state
  def id_from_assigns_parent(state, _), do: state

  def id_from_changeset({ :nok, _ }, %{ data: %{ id: nil }}), do: { :nok, nil }
  def id_from_changeset({ :nok, _ }, %{ data: %{ id: id }}) do
    { :ok, "process-#{id}-form" }
  end
  def id_from_changeset({ :ok, form_id }, _), do: { :ok, form_id }
end

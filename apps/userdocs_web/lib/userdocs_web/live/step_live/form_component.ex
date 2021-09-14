defmodule UserDocsWeb.StepLive.FormComponent do
  use UserDocsWeb, :live_component

  require Logger

  alias UserDocsWeb.AnnotationLive
  alias UserDocsWeb.ElementLive
  alias UserDocsWeb.Layout
  alias UserDocsWeb.PageLive
  alias UserDocsWeb.StepLive.FormComponent.Helpers

  alias UserDocs.Automation
  alias UserDocs.Automation.Step.BrowserEvents
  alias UserDocs.Automation.StepForm
  alias UserDocs.Web
  alias UserDocs.Web.Page
"""
  def preserve_existing_params(params, changeset) do
    params
    |> preserve_order(changeset)
    |> maybe_preserve_step_type_id(changeset)
  end

  def preserve_order(params, changeset) do
    order = Ecto.Changeset.get_field(changeset, :order)
    Map.put(params, "order", order)
  end

  def maybe_preserve_step_type_id(%{"step_type_id" => "do_not_update"} = params, changeset) do
    step_type_id = Ecto.Changeset.get_field(changeset, :step_type_id)
    Map.put(params, "step_type_id", step_type_id)
  end
  def maybe_preserve_step_type_id(params, _changeset), do: params

  def update(%{step_params: step_params}, socket) when step_params != nil do
    {socket, step_params}
    |> BrowserEvents.
  end
  """
  def update(%{id: id, step_params: step_params} = assigns,
  %{assigns: %{current_project: current_project, last_step_form: last_step_form}} = socket)
  when step_params != nil do
    #IO.puts("Update for existing form")
    with params <- BrowserEvents.cast(step_params),
      last_change <- StepForm.changeset(last_step_form, params),
      last_change <- Helpers.handle_enabled_fields(last_change, socket.assigns),
      last_step_form <- Ecto.Changeset.apply_changes(last_change),
      updated_params <- handle_param_updates(params, last_change, socket.assigns),
      updated_params <- Map.merge(params, updated_params),
      updated_params <- BrowserEvents.handle_page(updated_params, current_project),
      updated_params <- BrowserEvents.handle_element(updated_params, socket.assigns.data.elements),
      changeset <- build_changeset(socket, updated_params)
    do
      {
        :ok,
        socket
        |> assign(:id, id)
        |> assign(:step_params, nil)
        |> assign(:changeset, changeset)
        |> assign(:last_step_form, last_step_form)
      }
    end
  end
  def update(%{id: id, step_form: step_form, step_params: nil} = assigns, socket) do
    #IO.puts("Update for new form with nil params")
    step_form = Helpers.enabled_step_fields(step_form, assigns)
    step_form = Helpers.enabled_annotation_fields(step_form, assigns)
    changeset = Automation.change_step_form(step_form)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:last_step_form, step_form)
      |> assign(:changeset, changeset)
      |> assign(:select_lists, update_select_lists(assigns, step_form.page_id))
    }
  end
  # Here, we have to make some param updates, build a changeset, apply it, and put that form on the socket as last_
  def update(%{id: id, step_form: step_form, step_params: step_params, current_project: current_project} = assigns, socket) do
    #IO.puts("Update for new form with step params")
    with params when is_map(params) <- BrowserEvents.cast(step_params),
      params when is_map(params) <- BrowserEvents.handle_page(params, current_project),
      params when is_map(params) <- BrowserEvents.handle_element(params, assigns.data.elements),
      changeset <- build_changeset(assigns, step_form, params),
      {:ok, step_form} <- Ecto.Changeset.apply_action(changeset, :insert),
      step_form <- Helpers.enabled_step_fields(step_form, assigns),
      step_form <- Helpers.enabled_annotation_fields(step_form, assigns)
    do
      {
        :ok,
        socket
        |> assign(Map.put(assigns, :step_params, nil))
        |> assign(:state_opts, assigns.state_opts)
        |> assign(:last_step_form, step_form)
        |> assign(:changeset, changeset)
        |> assign(:select_lists, update_select_lists(assigns, step_form.page_id))
     }
    else
      {:error, changeset} ->
        {
          :ok,
          socket
          |> assign(Map.put(assigns, :step_params, nil))
          |> assign(:last_step_form, %StepForm{})
          |> assign(:changeset, changeset)
        }
      {:new_page, params} ->
        changeset = build_changeset(assigns, step_form, params)
        {:ok, step_form} = Ecto.Changeset.apply_action(changeset, :insert)
        {
          :ok,
          socket
          |> assign(Map.put(assigns, :step_params, nil))
          |> assign(:last_step_form, step_form |> Map.put(:page_form_enabled, true))
          |> assign(:changeset, changeset)
          |> assign(:select_lists, update_select_lists(assigns, step_form.page_id))
          |> put_flash(:info, "The page you're on doesn't exist. You must create it before you can create elements on it. Create your page, save, and re-open the form.")
        }
    end
  end
  def update(%{action: :save}, socket) do
    {:noreply, socket} = auto_save_step(socket, socket.assigns.action)
    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"step_form" => step_form_params}, socket) do
    original_step_form = socket.assigns.step_form
    last_step_form = socket.assigns.last_step_form

    last_change = last_change(socket, step_form_params)
    last_step_form = Ecto.Changeset.apply_changes(last_change)
    updated_params = handle_param_updates(step_form_params, last_change, socket.assigns)

    changeset =
      StepForm.changeset(original_step_form, updated_params)
      |> Map.put(:action, :validate)

      {
        :noreply,
        socket
        |> assign(:last_step_form, last_step_form)
        |> assign(:changeset, changeset)
     }
  end

  @impl true
  def handle_event("save", %{"step_form" => step_form_params}, socket) do
    save_step(socket, socket.assigns.action, step_form_params)
  end
  def handle_event("new-element", _, socket) do
    changeset = Automation.new_step_element(
      socket.assigns.step, socket.assigns.changeset)

    {
      :noreply,
      socket
      |> assign(:changeset, changeset)
      |> assign(:step, changeset.data)
   }
  end
  def handle_event("new-page", _, socket) do
    updated_params =
      socket.assigns.changeset.params
      |> Map.put("page_id", nil)
      |> Map.put("page", %{})

    changeset =
      StepForm.changeset(%StepForm{}, updated_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset)}
  end
  def handle_event("new-annotation", _, socket) do
    updated_params =
      socket.assigns.changeset.params
      |> Map.put("annotation_id", nil)
      |> Map.put("annotation", %{})

    changeset =
      StepForm.changeset(%StepForm{}, updated_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_param_updates(params, %Ecto.Changeset{} = changeset, state) do
    params
    |> maybe_update_page_params(state, Ecto.Changeset.get_change(changeset, :page_id, nil))
    |> maybe_update_element_params(state, Ecto.Changeset.get_change(changeset, :element_id, nil))
    |> maybe_update_annotation_params(state, Ecto.Changeset.get_change(changeset, :annotation_id, nil))
  end

  def maybe_update_page_params(%{} = params, _, nil), do: params
  def maybe_update_page_params(%{} = params, state, page_id) do
    page = UserDocs.Web.get_page!(page_id, state, state.state_opts)
    page_params = replace_params_with_fields(params["page"], page, UserDocs.Web.Page)
    Map.put(params, "page", page_params)
  end

  def maybe_update_element_params(%{} = params, _, nil), do: params
  def maybe_update_element_params(%{} = params, state, element_id) do
    element = UserDocs.Web.get_element!(element_id, state, state.state_opts)
    element_params = replace_params_with_fields(params["element"], element, UserDocs.Web.Element)
    Map.put(params, "element", element_params)
  end

  def maybe_update_annotation_params(%{} = params, _, nil), do: params
  def maybe_update_annotation_params(%{} = params, state, annotation_id) do
    annotation = UserDocs.Web.get_annotation!(annotation_id, state, state.state_opts)
    annotation_params = replace_params_with_fields(params["annotation"], annotation, UserDocs.Web.Annotation)
    Map.put(params, "annotation", annotation_params)
  end

  def replace_params_with_fields(nil, object, module) do
    replace_params_with_fields(%{}, object, module)
  end
  def replace_params_with_fields(params, nil, _module), do: params
  def replace_params_with_fields(params, object, module) do
    Enum.reduce(module.__schema__(:fields), params,
      fn(field, params) ->
        Map.put(params, to_string(field), Map.get(object, field))
      end
    )
  end

  defp auto_save_step(socket, :edit) do
    step_form_params = socket.assigns.changeset.params
    changeset = Automation.change_fields(socket.assigns.step, step_form_params)
    {:ok, step} = UserDocs.Repo.update(changeset)
    changeset = Automation.change_assocs(step, step_form_params)
    changeset = Automation.Step.names_changeset(changeset)
    case UserDocs.Repo.update(changeset) do
      {:ok, step} ->
        opts = socket.assigns.state_opts |> Keyword.put(:action, :update)
        UserDocs.Subscription.broadcast_children(step, changeset, opts)
        send(self(), {:broadcast, "update", step})
        Process.send_after(self(), :save_step_complete, 1000)
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = _changeset} ->
        temp_changeset = Automation.StepForm.changeset(socket.assigns.step_form, step_form_params)
        {:noreply, assign(socket, :changeset, temp_changeset)}
    end
  end

  defp auto_save_step(socket, :new) do
    step_params = socket.assigns.changeset.params
    step_type = Automation.get_step_type!(step_params["step_type_id"])
    step_params =
      step_params
      |> Map.put("name", step_type.name)
      |> Map.put("process_id", socket.assigns.parent.id)

    with {:ok, step} <- Automation.create_base_step(step_params),
      changeset <- Ecto.Changeset.cast(step, step_params, []),
      changeset <- Automation.Step.assoc_changeset(changeset),
      {:ok, step} <- UserDocs.Repo.update(changeset)
    do
      opts = socket.assigns.state_opts |> Keyword.put(:action, :update)
      UserDocs.Subscription.broadcast_children(step, changeset, opts)
      send(self(), {:broadcast, "create", step})
      Process.send_after(self(), :save_step_complete, 1)
      {:noreply, socket}
    else
      {:error, %Ecto.Changeset{} = _changeset} ->
        temp_changeset = Automation.StepForm.changeset(socket.assigns.step_form, step_params)
        {:noreply, assign(socket, :changeset, temp_changeset)}
    end
  end

  defp save_step(socket, :edit, step_form_params) do
    changeset = Automation.change_fields(socket.assigns.step, step_form_params)
    {:ok, step} = UserDocs.Repo.update(changeset)
    changeset = Automation.change_assocs(step, step_form_params)
    changeset = Automation.Step.names_changeset(changeset)
    case UserDocs.Repo.update(changeset) do
      {:ok, step} ->
        opts = socket.assigns.state_opts |> Keyword.put(:action, :update)
        UserDocs.Subscription.broadcast_children(step, changeset, opts)
        send(self(), {:broadcast, "update", step})
        {
          :noreply,
          socket
          |> put_flash(:info, "Step updated successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = _changeset} ->
        temp_changeset = Automation.StepForm.changeset(socket.assigns.step_form, step_form_params)
        {:noreply, assign(socket, :changeset, temp_changeset)}
    end
  end

  defp save_step(socket, :new, step_params) do
    step_type = Automation.get_step_type!(step_params["step_type_id"])
    params = Map.put(step_params, "name", step_type.name)
    with {:ok, step} <- Automation.create_base_step(params),
      changeset <- Ecto.Changeset.cast(step, params, []),
      changeset <- Automation.Step.assoc_changeset(changeset),
      {:ok, step} <- UserDocs.Repo.update(changeset)
    do
      opts = socket.assigns.state_opts |> Keyword.put(:action, :update)
      UserDocs.Subscription.broadcast_children(step, changeset, opts)
      send(self(), {:broadcast, "create", step})
      {
        :noreply,
        socket
        |> put_flash(:info, "Step created successfully")
        |> push_redirect(to: socket.assigns.return_to)
     }
    else
      {:error, %Ecto.Changeset{} = _changeset} ->
        temp_changeset = Automation.StepForm.changeset(socket.assigns.step_form, step_params)
        {:noreply, assign(socket, :changeset, temp_changeset)}
    end
  end

  def update_select_lists(%{select_lists: select_lists} = assigns, page_id) do
    select_lists
    |> Map.put(:elements, elements_select(assigns, page_id))
    |> Map.put(:annotations, annotations_select(assigns, page_id))
  end

  def elements_select(%{state_opts: state_opts} = socket, page_id) do
    opts = Keyword.put(state_opts, :filter, {:page_id, page_id})
    Web.list_elements(socket, opts)
    |> UserDocs.Helpers.select_list(:name, true)
  end

  def annotations_select(%{state_opts: state_opts} = socket, page_id) do
    opts = Keyword.put(state_opts, :filter, {:page_id, page_id})
    Web.list_annotations(socket, opts)
    |> UserDocs.Helpers.select_list(:name, true)
  end

  def last_change(%{assigns: %{last_step_form: last_step_form}} = socket, step_params) do
    last_step_form
    |> StepForm.changeset(step_params)
    |> Helpers.handle_enabled_fields(socket.assigns)
  end

  def build_changeset(%{assigns: %{changeset: changeset, step_form: step_form}} = socket, params) do
    step_form
    |> maybe_preload_page_project(socket)
    |> StepForm.changeset(params)
    |> Map.put(:action, :validate)
  end
  def build_changeset(%{changeset: changeset}, step_form, step_params) do
    Automation.change_step_form(step_form, step_params)
    |> Map.put(:changes, Map.get(changeset, :changes))
  end
  def build_changeset(_assigns, step_form, step_params), do: Automation.change_step_form(step_form, step_params)

  defp maybe_preload_page_project(%StepForm{page: %{project_id: project_id}} = step_form, %{assigns: %{state_opts: state_opts}} = socket) do
    project = UserDocs.Projects.get_project!(project_id, socket, state_opts)
    page = Map.put(step_form.page, :project, project)
    Map.put(step_form, :page, page)
  end
  defp maybe_preload_page_project(step_form, _), do: step_form
end

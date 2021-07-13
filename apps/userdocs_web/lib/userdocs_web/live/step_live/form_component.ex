defmodule UserDocsWeb.StepLive.FormComponent do
  use UserDocsWeb, :live_component

  require Logger

  alias UserDocsWeb.AnnotationLive
  alias UserDocsWeb.ElementLive
  alias UserDocsWeb.PageLive
  alias UserDocsWeb.Layout
  alias UserDocsWeb.StepLive.FormComponent.Helpers

  alias UserDocs.Automation
  alias UserDocs.Automation.StepForm
  alias UserDocs.Web

  @impl true
  def update(%{ step_params: step_params }, socket) when step_params != nil do
    original_step_form = socket.assigns.step_form
    last_step_form = socket.assigns.last_step_form

    last_change =
      last_step_form
      |> StepForm.changeset(step_params)
      |> Helpers.handle_enabled_fields(socket.assigns)

    last_step_form = Ecto.Changeset.apply_changes(last_change)

    updated_params = handle_param_updates(step_params, last_change, socket.assigns)
    updated_params = Map.merge(step_params, updated_params)

    changeset =
      StepForm.changeset(original_step_form, updated_params)
      |> Map.put(:action, :validate)

    {
      :ok,
      socket
      |> assign(:last_step_form, last_step_form)
      |> assign(:changeset, changeset)
      |> assign(:step_params, nil)
    }
  end
  def update(%{ step_form: step_form } = assigns, socket) do
    # This is because on a new form we need to make the changeset, but I think the second clause here is wrong.  Not sure why we'd reuse the existing changes
    changeset =
      case Map.get(socket.assigns, :changeset, nil) do
        nil -> Automation.change_step_form(step_form)
        changeset ->
          Automation.change_step_form(step_form)
          |> Map.put(:changes, Map.get(changeset, :changes))
      end

    step_form =
      step_form
      |> Helpers.enabled_step_fields(assigns)
      |> Helpers.enabled_annotation_fields(assigns)

    # We do this for the new case
    annotation_type_id =
      step_form
      |> Map.get(:annotation, nil)
      |> case do
        nil -> nil
        annotation -> Map.get(annotation, :annotation_type_id, nil)
      end

    select_lists =
      assigns.select_lists
      |> Map.put(:elements, elements_select(assigns, step_form.page_id))
      |> Map.put(:annotations, annotations_select(assigns, step_form.page_id))

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:select_lists, select_lists)
      |> assign(:state_opts, assigns.state_opts)
      |> assign(:last_step_form, step_form)
    }
  end

  @impl true
  def handle_event("validate", %{"step_form" => step_form_params}, socket) do
    original_step_form = socket.assigns.step_form
    last_step_form = socket.assigns.last_step_form

    last_change =
      last_step_form
      |> StepForm.changeset(step_form_params)
      |> Helpers.handle_enabled_fields(socket.assigns)

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
    changeset = Automation.new_step_page(
      socket.assigns.step, socket.assigns.changeset)

    {
      :noreply,
      socket
      |> assign(:changeset, changeset)
      |> assign(:step, changeset.data)
    }
  end
  def handle_event("new-annotation", _, socket) do
    changeset = Automation.new_step_annotation(
      socket.assigns.step, socket.assigns.changeset)

    {
      :noreply,
      socket
      |> assign(:changeset, changeset)
      |> assign(:step, changeset.data)
    }
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

  defp save_step(socket, :edit, step_form_params) do
    changeset = Automation.change_fields(socket.assigns.step, step_form_params)
    { :ok, step } = UserDocs.Repo.update(changeset)
    changeset = Automation.change_assocs(step, step_form_params)
    changeset = Automation.Step.names_changeset(changeset)
    case UserDocs.Repo.update(changeset) do
      {:ok, step} ->
        opts = socket.assigns.state_opts |> Keyword.put(:action, :update)
        UserDocs.Subscription.broadcast_children(step, changeset, opts)
        send(self(), { :broadcast, "update", step })
        {
          :noreply,
          socket
          |> put_flash(:info, "Step updated successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        temp_changeset = Automation.StepForm.changeset(socket.assigns.step_form, step_form_params)
        {:noreply, assign(socket, :changeset, temp_changeset)}
    end
  end

  defp save_step(socket, :new, step_params) do
    order = step_params["order"]
    step_type = Automation.get_step_type!(step_params["step_type_id"])
    name = order <> ": " <> step_type.name
    case Automation.create_nested_step(Map.put(step_params, "name", name)) do
      {:ok, step} ->
        send(self(), { :broadcast, "create", step })
        {
          :noreply,
          socket
          |> put_flash(:info, "Step created successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        temp_changeset = Automation.StepForm.changeset(socket.assigns.step_form, step_params)
        {:noreply, assign(socket, :changeset, temp_changeset)}
    end
  end



















































  def handle_event("new-content", %{ "annotation-id" => _ }, socket) do
    annotation = socket.assigns.step.annotation

    { :ok, new_annotation } =
      annotation
      |> UserDocs.Web.update_annotation(%{ content_id: nil })

    cleared_annotation = Map.put(new_annotation, :content, nil)

    old_annotation_changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.get_change(:annotation, UserDocs.Web.change_annotation(%Web.Annotation{}))

    annotation_params =
      old_annotation_changeset.params
      |> Map.put("content", "")
      |> Map.put("content_id", "")

    new_annotation_changeset =
      cleared_annotation
      |> UserDocs.Web.change_annotation(annotation_params)

    new_step =
      socket.assigns.step
      |> Map.put(:annotation, cleared_annotation)

    new_changeset =
      new_step
      |> Automation.Step.changeset(socket.assigns.changeset.params)
      |> Ecto.Changeset.put_change(:annotation, new_annotation_changeset)

    {
      :noreply,
      socket
      |> assign(:step, new_step)
      |> assign(:changeset, new_changeset)
    }
  end

  def elements_select(%{ state_opts: state_opts } = socket, page_id) do
    opts = Keyword.put(state_opts, :filter, { :page_id, page_id })
    Web.list_elements(socket, opts)
    |> UserDocs.Helpers.select_list(:name, true)
  end

  def annotations_select(%{ state_opts: state_opts } = socket, page_id) do
    opts = Keyword.put(state_opts, :filter, { :page_id, page_id })
    Web.list_annotations(socket, opts)
    |> UserDocs.Helpers.select_list(:name, true)
  end
end

defmodule UserDocsWeb.StepLive.FormComponent.Helpers do
  alias UserDocs.Annotations
  alias UserDocs.Automation
  alias UserDocs.Web
  alias UserDocs.Annotations.AnnotationForm
  alias UserDocs.Automation.StepForm

  def handle_enabled_fields(%Ecto.Changeset{} = changeset, state) do
    changeset
    |> maybe_update_enabled_step_fields(state)
    |> maybe_update_enabled_annotation_fields(state)
  end

  def maybe_update_enabled_step_fields(%Ecto.Changeset{changes: %{step_type_id: step_type_id}} = changeset, state) when step_type_id != nil do
    enabled_step_fields(changeset, state)
  end
  def maybe_update_enabled_step_fields(%Ecto.Changeset{} = changeset, _), do: changeset

  def maybe_update_enabled_annotation_fields(%Ecto.Changeset{changes: %{annotation: %{changes: %{annotation_type_id: _}}}} = changeset, state) do
    enabled_annotation_fields(changeset, state)
  end
  def maybe_update_enabled_annotation_fields(%Ecto.Changeset{} = changeset, _), do: changeset

  def enabled_step_fields(%Ecto.Changeset{changes: %{step_type_id: step_type_id}} = changeset, state) do
    step_type = Automation.get_step_type!(step_type_id, state, state.state_opts)
    enable_fields(changeset, StepForm.enabler_fields(), step_type.args)
  end
  def enabled_step_fields(%StepForm{step_type_id: nil} = step_form, _), do: step_form
  def enabled_step_fields(%StepForm{step_type_id: step_type_id} = step_form, state) do
    step_type = Automation.get_step_type!(step_type_id, state, state.state_opts)
    enable_fields(step_form, StepForm.enabler_fields(), step_type.args)
  end

  def enabled_annotation_fields(%Ecto.Changeset{} = changeset, state) do
    annotation_type_id = changeset.changes.annotation.changes.annotation_type_id
    annotation_type = Annotations.get_annotation_type!(annotation_type_id, state, state.state_opts)
    annotation_form = enable_fields(changeset.changes.annotation, AnnotationForm.enabler_fields(), annotation_type.args)
    Ecto.Changeset.put_change(changeset, :annotation, annotation_form)
  end
  def enabled_annotation_fields(%StepForm{annotation: nil} = step_form, _), do: step_form
  def enabled_annotation_fields(%StepForm{annotation: %{annotation_type_id: nil}} = step_form, _), do: step_form
  def enabled_annotation_fields(%StepForm{annotation: %{annotation_type_id: annotation_type_id} = annotation} = step_form, state) do
    annotation_type = Annotations.get_annotation_type!(annotation_type_id, state, state.state_opts)
    annotation_form = enable_fields(annotation, AnnotationForm.enabler_fields(), annotation_type.args)
    Map.put(step_form, :annotation, annotation_form)
  end

  def enable_fields(%Ecto.Changeset{} = changeset, fields, fields_to_enable) do
    Enum.reduce(fields, changeset,
      fn(enabler, inner_changeset) ->
        if String.replace(to_string(enabler), "_enabled", "") in fields_to_enable do
          case Ecto.Changeset.get_change(inner_changeset, enabler, nil) do
            nil -> Ecto.Changeset.put_change(inner_changeset, enabler, true)
            _change -> inner_changeset
          end
        else
          case Ecto.Changeset.get_change(inner_changeset, enabler, nil) do
            nil -> Ecto.Changeset.put_change(inner_changeset, enabler, false)
            _change -> inner_changeset
          end
        end
      end
    )
  end
  def enable_fields(object, fields, fields_to_enable) do
    Enum.reduce(fields, object,
      fn(enabler, inner_object) ->
        if String.replace(to_string(enabler), "_enabled", "") in fields_to_enable do
          Map.put(inner_object, enabler, true)
        else
          Map.put(inner_object, enabler, false)
        end
      end
    )
  end
end

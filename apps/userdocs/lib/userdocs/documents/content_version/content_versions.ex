defmodule UserDocs.Documents.ContentVersion.ContentVersions do


  alias UserDocs.Documents
  alias UserDocs.Web
  alias UserDocs.Automation
  alias UserDocs.Documents.ContentVersion

  require Logger

  def add_content_version(state) do
    # This is still a little hokey - some of this is dependant on the contents of the assigns.
    # Not everything is totally clear and explicit.  It expects
    # assigns:
    #   %{
    #       changeset: changeset,
    #       current_object: current_object,
    #       data: data,
    #       parent_id: parent_id
    #   }
    # Try and fetch the content versions from the content changes (indicates there's
    # Fresh changes).  If that fails, we need to go and get them from the "current_step"
    # It's definitely debatable whether I need to check the changes.  These will probably
    # Get applied to the current step all the time.
    existing_content_versions =
      try do
        state.changeset.changes.annotation.changes.content.changes.content_versions
      rescue
        _ ->
          Logger.warn("Failed to find the content versions in the changeset")
          state.current_object.annotation.content.content_versions
          |> Enum.map(&Documents.change_content_version(&1))
      end
    process =
      Automation.get_process!(state.parent_id, state, state.assigns.state_opts) #TEST

    content_versions =
      existing_content_versions
      |> Enum.concat([Documents.change_content_version(%ContentVersion{
          temp_id: UserDocs.ID.temp_id(),
          content_id: state.current_object.annotation.content.id,
          version_id: process.version_id,
          body: ""
        })])

      maybe_replace_content_changeset(
        state.changeset,
        state.current_object,
        content_versions
      )
  end

  def remove_content_version(state, remove_id) do
    Logger.debug("Removing Content Version #{remove_id} <- id")
    content_versions =
      state.changeset.changes.annotation.changes.content.changes.content_versions
      |> Enum.reject(fn %{data: data, changes: changes} ->
        Map.get(changes, :temp_id, data.temp_id) == remove_id
      end)

    maybe_replace_content_changeset(
      state.changeset,
      state.current_object,
      content_versions
    )
  end

  defp maybe_replace_content_changeset(changeset, step, content_versions) do
    content_changeset =
      try do
        changeset.changes.annotation.changes.content
        |> Ecto.Changeset.put_assoc(:content_versions, content_versions)
      rescue
        KeyError ->
          Logger.warn("Putting Content Versions in the content changeset failed")
          Documents.change_content(step.annotation.content, %{})
          |> Ecto.Changeset.put_assoc(:content_versions, content_versions)
      end

    annotation_changeset =
      try do
        changeset.changes.annotation
        |> Ecto.Changeset.put_assoc(:content, content_changeset)
      rescue
        KeyError ->
          Logger.warn("Putting Content in the Annotation changeset failed")
          Web.change_annotation(step.annotation, %{})
          |> Ecto.Changeset.put_assoc(:content, content_changeset)
      end

    try do
      changeset
      |> Ecto.Changeset.put_assoc(:annotation, annotation_changeset)
    rescue
      KeyError ->
        Logger.warn("Putting the Annotation in the Step changeset failed")
        Automation.change_step(step, %{})
        |> Ecto.Changeset.put_assoc(:annotation, annotation_changeset)
    end
  end
end

defmodule UserDocsWeb.ContentVersionLive.FormComponent do
  use UserDocsWeb, :live_component

  require Logger

  alias UserDocs.Projects
  alias UserDocs.Documents
  alias UserDocs.Documents.LanguageCode
  alias UserDocs.Documents.ContentVersion
  alias UserDocsWeb.DomainHelpers

  @impl true
  def update(%{content_version: content_version} = assigns, socket) do
    changeset = Documents.change_content_version(content_version)

    content_select_options =
      content(assigns, assigns.current_user.default_team_id)
      |> DomainHelpers.select_list_temp(:name, false)

    version_select_options =
      versions(assigns.current_user.default_team_id)
      |> DomainHelpers.select_list_temp(:name, false)

    selected_language_code = selected_language_code(content_version.language_code)
    language_code_select_options =
      language_codes(assigns)
      |> DomainHelpers.select_list_temp(:code, false)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:content_select_options, content_select_options)
     |> assign(:selected_content_id, content_version.content_id)
     |> assign(:version_select_options, version_select_options)
     |> assign(:selected_version_id, content_version.version_id)
     |> assign(:language_code_select_options, language_code_select_options)
     |> assign(:selected_language_code, selected_language_code)
    }
  end

  @impl true
  def handle_event("validate", %{"content_version" => content_version_params}, socket) do
    changeset =
      socket.assigns.content_version
      |> Documents.change_content_version(content_version_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"content_version" => content_version_params}, socket) do
    save_content_version(socket, socket.assigns.action, content_version_params)
  end

  defp save_content_version(socket, :edit, content_version_params) do
    case Documents.update_content_version(socket.assigns.content_version, content_version_params) do
      {:ok, _content_version} ->
        {:noreply,
         socket
         |> put_flash(:info, "Content version updated successfully")
         # |> push_redirect(to: socket.assigns.return_to)
         |> push_patch(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_content_version(socket, :new, content_version_params) do
    case Documents.create_content_version(content_version_params) do
      {:ok, _content_version} ->
        {:noreply,
         socket
         |> put_flash(:info, "Content version created successfully")
         # |> push_redirect(to: socket.assigns.return_to)
         |> push_patch(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp content(assigns, team_id) do
    try do
      assigns.select_lists.available_content
    rescue
      _ ->
        Logger.warn("ContentVersionLive.FormComponent reverting to database for content")
        Documents.list_content(%{}, %{team_id: team_id})
    end
  end

  defp versions(team_id) do
    Projects.list_versions(%{}, %{team_id: team_id})
  end

  defp language_codes(assigns) do
    try do
      assigns.select_lists.language_codes
    rescue
      _ ->
        Logger.warn("ContentVersionLive.FormComponent reverting to database for language codes")
        Documents.list_language_codes()
    end
  end

  defp selected_language_code(language_code = %LanguageCode{}), do: language_code.id
  defp selected_language_code(_), do: 0
end

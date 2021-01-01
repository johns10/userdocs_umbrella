defmodule UserDocsWeb.DocubitLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.Layout
  alias UserDocs.Documents
  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents.DocubitSetting

  @impl true
  def update(%{docubit: docubit} = assigns, socket) do
    changeset = Documents.change_docubit(docubit)
    settings_to_display = default_display_fields(docubit)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:settings_to_display, settings_to_display)
      |> assign(:display_settings_dropdown, false)
      |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"docubit" => docubit_params}, socket) do
    changeset =
      socket.assigns.docubit
      |> Documents.change_docubit(docubit_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"docubit" => docubit_params}, socket) do
    save_docubit(socket, socket.assigns.action, docubit_params)
  end

  def handle_event("display-setting-menu", _, socket) do
    {
      :noreply,
      socket
      |> assign(:display_settings_dropdown, not socket.assigns.display_settings_dropdown)
    }
  end

  def handle_event("add-setting", %{ "type" => type }, socket) do
    settings_to_display =
      socket.assigns.settings_to_display
      |> List.insert_at(-1, String.to_atom(type))
      |> Enum.uniq()
    {
      :noreply,
      socket
      |> assign(:settings_to_display, settings_to_display)
    }
  end

  defp save_docubit(socket, :edit, docubit_params) do
    case Documents.update_docubit(socket.assigns.docubit, docubit_params) do
      {:ok, docubit} ->
        message = %{ objects: docubit.docubits }
        UserDocsWeb.Endpoint.broadcast(socket.assigns.channel, "update", docubit)
        UserDocsWeb.Endpoint.broadcast(socket.assigns.channel, "update", message)
        send(self(), :close_modal)
        {:noreply,
          socket
          |> put_flash(:info, "Docubit updated successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def default_display_fields(docubit = %Docubit{ settings: %DocubitSetting{}}) do
    docubit
    |> Map.get(:settings, %DocubitSetting{})
    |> Map.take(DocubitSetting.__schema__(:fields))
    |> Enum.filter(fn({ _, value }) -> value != nil end)
    |> Keyword.keys()
  end
  def default_display_fields(_), do: []

  def do_render_setting_field(
        form,
        name,
        %{field_type: :select, select_options: select_options},
        value
      ) do
    Layout.select_input(form, name, select_options, [ value: value ])
  end

  def setting_attrs(name) do
    Kernel.apply(
      UserDocs.Documents.DocubitSettings,
      String.to_atom(name),
      []
    )
  end
end

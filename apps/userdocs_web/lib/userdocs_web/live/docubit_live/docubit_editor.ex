defmodule UserDocsWeb.DocubitEditorLive do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.DocubitEditorLive
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Root
  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:display_settings_menu, false)
    }
  end

  @impl true
  def update(assigns, socket) do
    IO.puts("Running Docubit Editor Update")
    docubit = assigns.docubit

    preloads = [
      :docubits,
      [ docubits: :content ],
      [ docubits: :file ],
      [ docubits: :through_annotation ],
      [ docubits: :through_step ],
      [ docubits: :docubit_type ],
      [ docubits: [ content: :content_versions ] ],
    ]

    opts =
      assigns.opts
      |> Keyword.put(:preloads, preloads)
      |> Keyword.put(:order, docubits: %{field: :order, order: :asc})

    preloaded_docubit = Documents.get_docubit!(assigns.docubit.id, assigns, opts)

    docubits =
      preloaded_docubit.docubits
      |> Enum.map(fn(d) -> Docubit.apply_context(d, docubit.context) end)

    docubit = Map.put(docubit, :docubits, docubits)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:docubit, docubit)
      |> assign(:renderer, Docubit.renderer(docubit))
    }
  end

  @impl true
  def render(assigns) do
    ~L"""
      <div class="mx-1 my-1 px-1 py-1 is-flex-grow-2"
        style="border: 1px solid LightGray; border-radius: 4px;"
        phx-hook="docubit"
        phx-target=<%= @myself.cid %>
        phx-value-docubit-id=<%= @docubit.id %>
        id=<%= @id %>
      >
        <div class="is-flex is-flex-direction-row is-justify-content-space-between py-1">
          <div><%= @docubit.docubit_type.name %></div>
          <div class="py-0">
            <div class="dropdown is-active">
              <i class="fa fa-gear"
                phx-click="display-settings-menu"
                phx-target="<%= @myself.cid %>"
              ></i>
              <%= if @display_settings_menu do %>
                <%= docubit_editor_options_dropdown(assigns) %>
              <% end %>
            </div>
          </div>
        </div>
        <%= live_component(@socket, @renderer, [
          current_language_code_id: @current_language_code_id,
          current_version_id: @current_version_id,
          docubit: @docubit,
          parent_cid: @myself.cid,
          id: "docubit-" <> @docubit.docubit_type.name <> Integer.to_string(@docubit.id)
        ]) do %>
          <%= for docubit <- @docubit.docubits do %>
            <%= live_component(@socket, DocubitEditorLive, [
              id: "docubit-editor-" <> Integer.to_string(docubit.id),
              current_language_code_id: @current_language_code_id,
              current_version_id: @current_version_id,
              current_team_id: @current_team_id,
              docubit: docubit,
              opts: @opts,
              root_cid: @root_cid,
              parent_cid: @myself.cid,
              data: @data
            ]) %>
          <% end %>
        <% end %>
      </div>
    """
  end

  def docubit_editor_options_dropdown(assigns) do
    ~L"""
      <div class="dropdown-menu" id="dropdown-menu" role="menu">
        <div class="dropdown-content">
          <a href="#"
            class="dropdown-item"
            phx-click="delete-docubit"
            phx-target=<%= @parent_cid %>
            phx-value-id=<%= @docubit.id %>>
            Delete
          </a>
          <a href="#"
            class="dropdown-item"
            phx-click="edit-docubit"
            phx-target=<%= @parent_cid %>
            phx-value-id=<%= @docubit.id %>>
            Settings
          </a>
        </div>
      </div>
    """
  end

  def handle_event("delete-docubit", %{"id" => id }, socket) do
    id = String.to_integer(id)

    attrs = %{
      id: socket.assigns.docubit.id,
      document_version_id: socket.assigns.docubit.document_version_id,
      docubits:
        Enum.map(
          socket.assigns.docubit.docubits,
          fn docubit ->
            case docubit.id == id do
              true -> Map.take(docubit, UserDocs.Documents.Docubit.__schema__(:fields)) |> Map.put(:delete, true)
              false -> Map.take(docubit, Docubit.__schema__(:fields))
            end
          end
        )
    }

    case Documents.delete_docubit_from_docubits(socket.assigns.docubit, attrs) do
      {:error, changeset} ->
        IO.puts("Delete failed")

        {
          :noreply,
          socket
          |> put_flash(:info, "Deleting Docubit Failed")
        }

      {deleted_docubit, _} ->
        UserDocsWeb.Endpoint.broadcast(Defaults.channel(socket), "delete", deleted_docubit)

        {
          :noreply,
          socket
          |> put_flash(:info, "Deleted Docubit")
        }
    end
  end
  def handle_event("create-docubit", %{"type" => type, "docubit-id" => _docubit_id}, socket) do
    send(self(), {:create_docubit, %{type: type, docubit: socket.assigns.docubit}})
    {:noreply, socket}
  end

  def handle_event(
        "docubit_drop",
        %{"docubit-id" => _docubit_id, "object-id" => object_id, "type" => type},
        socket
      ) do
    schema =
      case type do
        "Step" -> UserDocs.Automation.Step
        "Annotation" -> UserDocs.Web.Annotation
        "Content" -> UserDocs.Documents.Content
      end

    preloads =
      case type do
        "Content" -> [:annotation, :content_versions]
        "Step" -> []
        "Annotation" -> []
      end

    opts =
      socket.assigns.opts
      |> Keyword.put(:preloads, preloads)

    object = StateHandlers.get(socket, String.to_integer(object_id), schema, opts)
    object = StateHandlers.preload(socket, object, opts)
    docubit = socket.assigns.docubit

    docubit =
      case Docubit.hydrate(docubit, object) do
        %Docubit{} = docubit -> docubit
        { :error, message } -> IO.puts(inspect(message))
      end

    Phoenix.LiveView.send_update(
      socket.assigns.renderer,
      current_language_code_id: socket.assigns.current_language_code_id,
      current_version_id: socket.assigns.current_version_id,
      docubit: docubit,
      parent_cid: self(),
      id: "docubit-" <> docubit.docubit_type.name <> Integer.to_string(docubit.id)
    )

    {
      :noreply,
      socket
      |> assign(:docubit, docubit)
    }
  end
  def handle_event("display-settings-menu", _, socket) do
    IO.puts("Create Docubit")
    {:noreply, assign(socket, :display_settings_menu, not socket.assigns.display_settings_menu)}
  end
  def handle_event("edit-docubit" = name, %{"id" => id}, socket) do
    params =
      %{}
      |> Map.put(:docubit, socket.assigns.docubit)
      |> Map.put(:channel, Defaults.channel(socket))
      |> Map.put(:opts, socket.assigns.opts)

    Root.handle_event(name, params, socket)
  end
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)
end

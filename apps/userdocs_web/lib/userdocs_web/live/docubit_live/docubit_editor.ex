defmodule UserDocsWeb.DocubitEditorLive do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.DocubitEditorLive
  alias UserDocsWeb.Endpoint
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Root
  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents

  @impl true
  def mount(socket) do
    Endpoint.subscribe("docubit-editor")
    {
      :ok,
      socket
      |> assign(:display_settings_menu, false)
    }
  end

  @impl true
  def update(%{ close_all_dropdowns: true }, socket) do
    { :ok, assign(socket, :display_settings_menu, false) }
  end
  def update(assigns, socket) do
    docubit = assigns.docubit

    preloads = [
      :docubits,
      :docubit_type,
      [ docubits: :content ],
      [ docubits: :screenshot ],
      [ docubits: :through_annotation ],
      [ docubits: :through_step ],
      [ docubits: :docubit_type ],
      [ docubits: [ content: :content_versions ] ],
      [ docubits: [ content: :annotation ] ],
      [ docubits: [ content: [ content_versions: :version ]]]
    ]

    state_opts =
      get_state_opts(assigns)
      |> Keyword.put(:preloads, preloads)
      |> Keyword.put(:order, docubits: %{field: :order, order: :asc})

    preloaded_docubit =
      Documents.get_docubit!(assigns.docubit.id, assigns, state_opts)

    docubits =
      preloaded_docubit.docubits
      |> Enum.map(
        fn(d) ->
          Docubit.apply_context(d, docubit.context)
        end)

    final_docubit = Map.put(docubit, :docubits, docubits)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:docubit, final_docubit)
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
          <div>
            <%= @renderer.header(assigns) %>
          </div>
          <div class="is-flex is-flex-direction-row">
            <%= if is_integer(@parent_cid) do %>
              <%= if @docubit.order > 0 do %>
                <%= link to: "#", phx_click: "move-docubit-up-one", class: "px-1",
                  phx_value_docubit_order: @docubit.order, phx_target: @parent_cid do %>
                  <i class="fa fa-arrow-up"></i>
                <% end %>
              <% end %>
              <%= if @docubit.order < @quantity_docubits - 1 do %>
                <%= link to: "#", phx_click: "move-docubit-down-one", class: "px-1",
                  phx_value_docubit_order: @docubit.order, phx_target: @parent_cid do %>
                  <i class="fa fa-arrow-down"></i>
                <% end %>
              <% end %>
            <% end %>
            <div class="pl-1">
              <div class="<%= dropdown_is_active?(@display_settings_menu) %>" >
                <%= link to: "#", phx_click: "display-settings-menu", phx_value_docubit_id: @docubit.id, phx_target: @myself.cid do %>
                  <i class="fa fa-gear"></i>
                <% end %>
                <div class="dropdown-menu" id="dropdown-menu" role="menu">
                  <div class="dropdown-content">
                    <%= if is_integer(@parent_cid) do %>
                      <a href="#"
                        class="dropdown-item"
                        phx-click="delete-docubit"
                        phx-target=<%= @parent_cid %>
                        phx-value-id=<%= @docubit.id %>>
                        Delete
                      </a>
                    <% end %>
                    <a href="#"
                      class="dropdown-item"
                      phx-click="edit-docubit"
                      phx-target=<%= @myself.cid %>
                      phx-value-id=<%= @docubit.id %>>
                      Settings
                    </a>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <%= live_component(@socket, @renderer, [
          editor: true,
          component: true,
          role: :editor,
          current_language_code_id: @current_language_code_id,
          current_version: @current_version,
          docubit: @docubit,
          parent_cid: @myself.cid,
          state_opts: get_state_opts(assigns),
          id: "docubit-" <> @docubit.docubit_type.name <> Integer.to_string(@docubit.id),
          img_path: @img_path
        ]) do %>
          <%= for docubit <- @docubit.docubits do %>
            <%= live_component(@socket, DocubitEditorLive, [
              id: "docubit-editor-" <> Integer.to_string(docubit.id),
              current_language_code_id: @current_language_code_id,
              current_version: @current_version,
              current_team: @current_team,
              document_id: @document_id,
              docubit: docubit,
              state_opts: get_state_opts(assigns),
              root_cid: @root_cid,
              parent_cid: @myself.cid,
              data: @data,
              channel: @channel,
              img_path: @img_path,
              quantity_docubits: Enum.count(@docubit.docubits),
            ]) %>
          <% end %>
        <% end %>
      </div>
    """
  end

  def dropdown_is_active?(true), do: "dropdown is-right is-active"
  def dropdown_is_active?(false), do: "dropdown is-right"

  def get_state_opts(assigns) do
    case Map.get(assigns, :state_opts, nil) do
      nil -> raise(RuntimeError, "Failed to get state opts from assigns")
      [ _ | _ ] = state_opts -> state_opts
    end
  end

  def handle_event(socket, "delete", payload, state_opts) do
    StateHandlers.delete(socket, payload, state_opts)
  end
  @impl true
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
      {:error, _changeset} ->
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
  def handle_event("create-docubit", %{"type" => type, "docubit-id" => docubit_id}, socket) do
    send(self(), { :close_all_dropdowns, [ String.to_integer(docubit_id) ] })
    send(self(), { :create_docubit, %{type: type, docubit: socket.assigns.docubit}} )
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
        "Content" -> [
          :annotation,
          :content_versions,
          [ content_versions: :version]
        ]
        "Step" -> [
          :annotation,
          [ annotation: :content ],
          [ annotation: [ content: :content_versions ]],
          [ annotation: [ content: [ content_versions: :version ]]],
        ]
        "Annotation" -> [
          :content,
          [ content: :content_versions ],
          [ content: [ content_versions: :version ]]
        ]
      end

    state_opts =
      get_state_opts(socket.assigns)
      |> Keyword.put(:preloads, preloads)

    object = StateHandlers.get(socket, String.to_integer(object_id), schema, state_opts)
    object = StateHandlers.preload(socket, object, state_opts)
    docubit = socket.assigns.docubit

    case Docubit.hydrate(docubit, object) do
      %Docubit{} = docubit ->
        UserDocsWeb.Endpoint.broadcast(socket.assigns.channel, "update", docubit)
        Phoenix.LiveView.send_update(
          socket.assigns.renderer,
          current_language_code_id: socket.assigns.current_language_code_id,
          current_version: socket.assigns.current_version,
          docubit: docubit,
          parent_cid: socket.assigns.myself.cid,
          id: "docubit-" <> docubit.docubit_type.name <> Integer.to_string(docubit.id)
        )

        {
          :noreply,
          socket
          |> assign(:docubit, docubit)
        }
      { :error, message } ->
        IO.puts("Hydrate Error")
        {
          :noreply,
          socket
          |> put_flash(:info, inspect(message))
          |> push_patch(to: Routes.document_editor_path(socket, :edit, socket.assigns.document_id))
        }
      end


  end
  def handle_event("move-docubit-up-one", %{"docubit-order" => docubit_order }, socket) do
    IO.puts("move-docubit #{docubit_order} up-one")
    docubit_order = String.to_integer(docubit_order)
    first_order = docubit_order - 1
    second_order = docubit_order

    updated_docubit = swap_adjacent_docubits(socket.assigns.docubit, first_order, second_order)

    { :noreply, assign(socket, :docubit, updated_docubit) }
  end
  def handle_event("move-docubit-down-one", %{"docubit-order" => docubit_order }, socket) do
    IO.puts("move-docubit #{docubit_order} down-one")
    docubit_order = String.to_integer(docubit_order)
    first_order = docubit_order
    second_order = docubit_order + 1

    updated_docubit = swap_adjacent_docubits(socket.assigns.docubit, first_order, second_order)

    { :noreply, assign(socket, :docubit, updated_docubit) }
  end
  def handle_event("display-settings-menu", %{"docubit-id" => docubit_id}, socket) do
    send(self(), { :close_all_dropdowns, [ String.to_integer(docubit_id) ] })
    {:noreply, assign(socket, :display_settings_menu, not socket.assigns.display_settings_menu)}
  end
  def handle_event("edit-docubit" = name, %{"id" => id}, socket) do
    IO.puts("Handling event edit-docubit")
    params =
      %{}
      |> Map.put(:docubit_id, String.to_integer(id))
      |> Map.put(:docubit, socket.assigns.docubit)
      |> Map.put(:channel, Defaults.channel(socket))
      |> Map.put(:state_opts, get_state_opts(socket.assigns))

    { :noreply, invalid_socket } = Root.handle_event(name, params, socket)
    send(self(), { :update_form_data, invalid_socket.assigns.form_data })
    { :noreply, socket }
  end
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  def swap_adjacent_docubits(parent_docubit, first_order, second_order) do
    parent_address = parent_docubit.address

    attrs = Enum.map(parent_docubit.docubits,
      fn(d) ->
        attrs = Map.take(d, Docubit.__schema__(:fields))
        case attrs.order do
          order when order == second_order ->
            attrs
            |> Map.put(:order, first_order)
            |> Map.put(:address, List.insert_at(parent_address, -1, first_order))
          order when order == first_order ->
            attrs
            |> Map.put(:order, second_order)
            |> Map.put(:address, List.insert_at(parent_address, -1, second_order))
          _ -> attrs
        end
      end
    )
    |> Enum.sort(fn(x, y) -> x.order < y.order end)

    { :ok, updated_docubit } = Documents.update_docubit(parent_docubit, %{ docubits: attrs })
    updated_docubit
  end
end

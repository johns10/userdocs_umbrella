defmodule UserDocsWeb.DocumentLive.Editor do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  @allowed_step_types ["Full Screen Screenshot", "Element Screenshot"]

  require Logger

  alias UserDocsWeb.DomainHelpers

  alias UserDocs.Documents
  alias UserDocs.Documents.Editor

  alias UserDocs.Web
  alias UserDocs.Documents

  alias UserDocs.Automation

  alias UserDocs.Users

  @impl true
  def mount(_params, session, socket) do
    {:ok,
      socket
      |> maybe_assign_current_user(session)
      |> assign(:dragging, nil)
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    IO.puts("Opening editor")
    document = Documents.get_document!(id, %{version: true})

    changeset = Documents.change_document(document)

    team = team(document.version_id)

    pages = pages(document.version_id)
    page_select_list =
      DomainHelpers.select_list_temp(pages, :name, false)

    processes = processes(document.version_id)
    process_select_list =
      DomainHelpers.select_list_temp(processes, :name, false)

    language_codes = language_codes()
    language_codes_select_options =
      DomainHelpers.select_list_temp(language_codes, :code, false)

    current_process = Enum.at(processes, 0)
    current_page = Enum.at(pages, 0)
    current_language_code = Enum.at(language_codes, 0)

    steps = steps(team.id)
    annotations = annotations(team.id)
    content = content(team.id)

    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:document, document)
      |> assign(:changeset, changeset)
      |> assign(:page, pages)
      |> assign(:process, processes)
      |> assign(:step, steps)
      |> assign(:annotation, annotations)
      |> assign(:content, content)
      |> assign(:language_codes, language_codes)
      |> assign(:current_page, current_page)
      |> assign(:current_process, current_process)
      |> assign(:current_language_code, current_language_code)
      |> assign(:page_select_list, page_select_list)
      |> assign(:process_select_list, process_select_list)
      |> assign(:language_codes_select_options, language_codes_select_options)
      |> assign_body()
    }
  end

  @impl true
  def handle_event("editor_drag_start", %{ "type" => type, "id" => id}, socket) do
    IO.puts("Started dragging #{type}, id #{id} from editor panel")

    {
      :noreply,
      socket
      |> assign(:dragging, %{ type: type, id: id })
    }
  end

  @impl true
  def handle_event("add_column",
    %{"row-count" => row_count, "column-count" => column_count},
    socket = %{ assigns: %{ document: document }}
  ) when is_binary(row_count) and is_binary(column_count) do

    payload = %{
      row_count: String.to_integer(row_count),
      column_count: String.to_integer(column_count)
    }

    document =
      Editor.add_new_column_to_body(document, payload)

    { _status, document } =
      Documents.update_document(socket.assigns.document,
        %{body: document.body})

    {
      :noreply,
      socket
      |> assign(:document, document)
      |> assign(:changeset, Documents.change_document(document))
      |> assign_body()
    }
  end

  @impl true
  def handle_event("add_row", payload = %{"row-count" =>  _}, socket = %{ assigns: %{ document: document }}) do
    document = Editor.add_new_row_to_body(document, payload)

    { status, document } =
      Documents.update_document(socket.assigns.document,
        %{body: document.body})

    {
      :noreply,
      socket
      |> assign(:document, document)
      |> assign(:changeset, Documents.change_document(document))
      |> assign_body()
    }
  end

  @impl true
  def handle_event("docubit_drop", %{ "element-id" => element_id, "column-count" => column_count, "row-count" => row_count}, socket
  ) when is_binary(column_count) and is_binary(row_count) do
    IO.puts("Dropping on docubit element #{element_id} column #{column_count}, row #{row_count}")
    Logger.debug(socket.assigns.dragging)
    type = socket.assigns.dragging.type
    id = String.to_integer(socket.assigns.dragging.id)
    Logger.debug(type)
    Logger.debug(id)

    document = Editor.add_item_to_document_column(
      socket.assigns.document,
      String.to_integer(row_count),
      String.to_integer(column_count),
      type,
      id
    )

    { _status, document } =
      Documents.update_document(socket.assigns.document,
        %{body: document.body})

    {
      :noreply,
      socket
      |> assign(:document, document)
      |> assign_body()
    }
  end

  @impl true
  def handle_event("change-language", %{"language" => %{"id" => id}}, socket)
  when is_binary(id) do
    IO.puts("Changing Language")
    Logger.debug(id)
    language_code_id = String.to_integer(id)

    current_language_code =
      socket.assigns.language_codes
      |> Enum.filter(fn(c) -> c.id == language_code_id end)
      |> Enum.at(0)

    {
      :noreply,
      socket
      |> assign(:current_language_code, current_language_code)
      |> assign_body()
    }
  end

  @impl true
  def handle_event("delete_body_item", %{ "body-element-id" => address }, socket) do
    IO.puts("Handling a delete item event")
    new_body = delete_body_item(address, socket.assigns.document.body)

    { _status, new_document } =
      Documents.update_document(socket.assigns.document,
        %{body: new_body})

    {
      :noreply,
      socket
      |> assign(:document, new_document)
      |> assign_body()
    }
  end

  def delete_body_item(address, docubit) when is_binary(address) do
    address
    |> parse_address()
    |> delete_body_item(docubit)
  end
  def delete_body_item([ ], docubit) do
    raise(RunTimeError, message: "address list was already empty")
  end
  def delete_body_item([ h ], docubit) do
    IO.puts("at end of list")
    new_children = List.delete_at(docubit["children"], h)
    Map.put(docubit, "children", new_children)
  end
  def delete_body_item([ h | t ], docubit) do
    IO.puts("not at end of list")
    child = Enum.at(docubit["children"], h)
    child = delete_body_item(t, child)
    new_children = List.replace_at(docubit["children"], h, child)
    Map.put(docubit, "children", new_children)
  end

  def locate_body_item(body, address) do
    address
    |> parse_address()
    |> Enum.reduce(body,
      fn(id, docubit) ->
        Enum.at(docubit["children"], id)
      end)
  end

  def parse_address(address) do
    address
    |> String.split(":")
    |> (fn([ _ | t ]) -> t end).()
    |> Enum.map(fn(e) -> String.to_integer(e) end)
  end

  def inspect_second({ body, second }) do
    { body, second }
  end

  defp assign_body(socket) do
    case socket.assigns.document.body do
      nil -> raise(ArgumentError, "UserDocsWeb.DocumentLive.Editor.body/1 can't parse a null body")
      _ -> assign(socket, :body, body(socket))
    end
  end
  defp body(socket) do
    socket.assigns.document.body
    |> UserDocs.Documents.OldDocuBit.parse(socket)
    |> UserDocs.Documents.OldDocuBit.render_editor(%{renderer: "Editor", prefix: ""})
  end

  defp page_title(:show), do: "Show Document"
  defp page_title(:edit), do: "Edit Document"

  defp team(version_id) do
    Users.get_version_team!(version_id)
  end

  defp pages(version_id) do
    Web.list_pages(%{}, %{version_id: version_id})
  end

  defp processes(version_id) do
    Automation.list_processes(%{}, %{version_id: version_id})
  end

  defp content(team_id) do
    Documents.list_content(
      %{ content_versions: true },
      %{ team_id: team_id }
    )
  end

  defp steps(team_id) do
    Automation.list_steps(
      %{
        screenshot: true,
        step_type: true,
        annotation: true,
        annotation_type: true,
        content_versions: true,
        file: true
      },
      %{team_id: team_id}
    )
    #|> Enum.filter(fn(s) -> s.step_type.name in @allowed_step_types end)
  end

  defp process_steps(process_id, steps) when is_integer(process_id) do
    steps
    |> Enum.filter(fn(s) -> s.process_id == process_id end)
    |> Enum.filter(fn(s) -> s.step_type.name in @allowed_step_types end)
  end

  defp annotations(team_id) do
    Web.list_annotations(
      %{
        content: true,
        content_versions: true,
        annotation_type: true
      },
      %{team_id: team_id}
    )
  end

  defp process_annotations(page_id, annotations) do
    IO.puts("Process annotations")
    annotations
    |> Enum.filter(fn(a) -> a.page_id == page_id end)
  end

  defp panel_content(_, content), do: content

  defp language_codes() do
    Logger.debug("UserDocsWeb.DocumentLive.Editor querying language codes")
    Documents.list_language_codes()
  end
end

defmodule UserDocsWeb.ElementLive.FormComponent do
  use UserDocsWeb, :live_component

  require Logger

  alias UserDocs.Web

  alias UserDocsWeb.LiveHelpers
  alias UserDocsWeb.DomainHelpers
  alias UserDocsWeb.Layout

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:copied_selector, None)

    {:ok, socket}
  end

  @impl true
  def update(%{element: element} = assigns, socket) do
    changeset = Web.change_element(element)
    maybe_parent_id = DomainHelpers.maybe_parent_id(assigns, :page_id)

    strategies_select_options =
      strategies(assigns)
      |> DomainHelpers.select_list_temp(:name, false)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:read_only, LiveHelpers.read_only?(assigns))
     |> assign(:maybe_action, LiveHelpers.maybe_action(assigns))
     |> assign(:maybe_parent_id, maybe_parent_id)
     |> assign(:selector_field_id, selector_field_id(assigns, changeset))
     |> assign(:strategy_field_id, strategy_field_id(assigns, changeset))
     |> assign(:strategies_select_options, strategies_select_options)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"element" => element_params}, socket) do
    IO.puts("Validating")
    changeset =
      socket.assigns.element
      |> Web.change_element(element_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"element" => element_params}, socket) do
    save_element(socket, socket.assigns.action, element_params)
  end

  def handle_event("test_selector", %{ "element-id" => element_id }, socket) do
    element_id = String.to_integer(element_id)

    IO.puts("Testing selector")

    element =
      socket.assigns.select_lists.available_elements
      |> Enum.filter(fn(e) -> e.id == element_id end)
      |> Enum.at(0)

    payload =  %{
      type: "step",
      payload: %{
        process: %{
          steps: [
            %{
              id: 0,
              selector: element.selector,
              strategy: element.strategy,
              step_type: %{
                name: "Test Selector"
              }
            }
           ],
        },
        element_id: socket.assigns.id,
        status: "not_started",
        active_annotations: []
      }
    }

    {
      :noreply,
      socket
      |> push_event("test_selector", payload)
    }
  end

  defp save_element(socket, :edit, element_params) do
    case Web.update_element(socket.assigns.element, element_params) do
      {:ok, _element} ->
        {:noreply,
         socket
         |> put_flash(:info, "Element updated successfully")
         |> push_patch(to: socket.assigns.return_to)
         # |> LiveHelpers.maybe_push_redirect()
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_element(socket, :new, element_params) do
    case Web.create_element(element_params) do
      {:ok, _element} ->
        {:noreply,
         socket
         |> put_flash(:info, "Element created successfully")
         |> push_patch(to: socket.assigns.return_to)
         #|> LiveHelpers.maybe_push_redirect()
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp strategies(assigns) do
    try do
      assigns.select_lists.strategies
    rescue
      _ ->
        Logger.warn("ElementLive.FormComponent Failed to fetch strategies from assigns, falling back to query")
        Web.list_strategies()
    end
  end

  defp strategy_field_id(assigns, changeset) do
    "page-"
    <> Integer.to_string(DomainHelpers.maybe_parent_id(assigns, :page_id))
    <> "-element-"
    <> LiveHelpers.maybe_value(changeset.data.id, "new")
    <> "-form-strategy-field"
  end

  defp selector_field_id(assigns, changeset) do
    "page-"
    <> Integer.to_string(DomainHelpers.maybe_parent_id(assigns, :page_id))
    <> "-element-"
    <> LiveHelpers.maybe_value(changeset.data.id, "new")
    <> "-form-selector-field"
  end
end

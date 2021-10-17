defmodule UserDocsWeb.PageLive.Show do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Web
  alias UserDocsWeb.Root
  alias UserDocsWeb.ProcessLive.Loaders

  def data_types do
    [
      UserDocs.Web.AnnotationType,
      UserDocs.Web.Strategy,
      UserDocs.Web.Annotation,
      UserDocs.Web.Element,
      UserDocs.Web.Page,
      UserDocs.Projects.Project
   ]
  end

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> Root.apply(session, data_types())
      |> initialize()
   }
  end

  def initialize(%{assigns: %{auth_state: :not_logged_in}} = socket), do: socket
  def initialize(socket) do
    opts = socket.assigns.state_opts
    socket
    |> Web.load_annotation_types(opts)
    |> Web.load_strategies(opts)
    |> Loaders.pages(opts)
    |> Loaders.annotations(opts)
    |> Loaders.elements(opts)
    |> Loaders.projects(opts)
  end


  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:page, Web.get_page!(id))
      |> prepare_elements(String.to_integer(id))
    }
  end

  defp prepare_elements(socket, page_id) do
    preloads =
      [
        :strategy,
        :annotations,
        [annotation: :annotation_type]
     ]

     opts =
       socket.assigns.state_opts
       |> Keyword.put(:preloads, preloads)
       |> Keyword.put(:order, [%{field: :name, order: :asc}])
       |> Keyword.put(:filter, {:page_id, page_id})

    IO.inspect(Web.list_elements(socket, opts))

    assign(socket, :elements, Web.list_elements(socket, opts))
  end

  defp page_title(:show), do: "Show Page"
  defp page_title(:edit), do: "Edit Page"
end

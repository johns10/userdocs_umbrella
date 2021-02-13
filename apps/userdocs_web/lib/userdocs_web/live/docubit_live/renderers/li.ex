defmodule UserDocsWeb.DocubitLive.Renderers.Li do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents.Docubit.Context
  alias UserDocs.Web.Annotation

  alias UserDocsWeb.DocubitLive.Renderers.Base
  alias UserDocsWeb.DocubitLive.AddDocubitOptions

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:display_create_menu, false)
    }
  end

  @impl true
  def update(%{ docubit: %{} = docubit} = assigns, socket) do
    content = Base.display_content(assigns, docubit)
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:content, content)
    }
  end

  def header(assigns) do
    ["LI"]
    |> Base.maybe_content_header(assigns)
  end

  @impl true
  def render(assigns) do
    ~L"""
    <<%= outer_tag(assigns) %>
      <%= for {key, value} <- li_opts(@docubit) do %>
        <%= key %>="<%= value %>"
      <% end %>>
      <%= Base.maybe_render_prefix(@content) %>
      <%= @content.body %>
      <%= Base.render_inner_content(assigns) %>
      <%= AddDocubitOptions.render(assigns) %>
    </li>
    """
  end

  @impl true
  def handle_event("display-create-menu", _, socket) do
    { :noreply, AddDocubitOptions.display_create_menu(socket) }
  end

  def outer_tag(%{ editor: true }), do: "div"
  def outer_tag(%{ editor: false }), do: "li"

  def li_opts(docubit) do
    settings =
      docubit
      |> extract_context()
      |> extract_settings()

    []
    |> maybe_name_prefix(Map.get(settings, :name_prefix, nil), docubit)
  end

  def maybe_name_prefix(opts, nil, _), do: opts
  def maybe_name_prefix(opts, false, _), do: opts
  def maybe_name_prefix(opts, true, %Docubit{ through_annotation: %Annotation{} = annotation }) do
    Keyword.put(opts, :value, annotation.label)
  end
  def maybe_name_prefix(opts, true, %Docubit{ through_annotation: nil }) , do: opts

  def extract_context(%Docubit{ context: %Context{} = context}), do: context
  def extract_context(_), do: raise(RuntimeError, "Malformed Docubit submitted to extract_context")

  def extract_settings(%Context{ settings: settings }), do: settings
  def extract_settings(_), do: raise(RuntimeError, "Malformed Settings submitted to extract_settings")
end

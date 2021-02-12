defmodule UserDocsWeb.DocubitLive.Renderers.Column do
  use UserDocsWeb, :live_component
  use Phoenix.HTML
  alias UserDocsWeb.DocubitLive.AddDocubitButton
  alias UserDocsWeb.DocubitLive.Renderers.Base
  alias UserDocsWeb.DocubitLive.AddDocubitOptions

  def header(_), do: "Column"

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:display_create_menu, false)
    }
  end

  @impl true
  def render(%{ role: :html_export } = assigns) do
    ~L"""
    <div class="column">
      <%= Base.render_inner_content(assigns) %>
    </div>
    """
  end

  def render(assigns) do
    ~L"""
      <div class="">
        <%= Base.render_inner_content(assigns) %>
        <%= AddDocubitOptions.render(assigns) %>
      </div>
    """
  end

  @impl true
  def handle_event("display-create-menu", _, socket) do
    { :noreply, AddDocubitOptions.display_create_menu(socket) }
  end
end

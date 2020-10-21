defmodule UserDocsWeb.StepLive.ShowComponent do
  use UserDocsWeb, :live_component
  use Phoenix.HTML


  #TODO: Fix this, it's terrible
  @hard_coded_path_hack "http://localhost:4000"

  @impl true
  def render(assigns) do
    ~L"""
    <body>
      <section class="section">
        <div class="container">
          <div><%= @image %></div>
        </div>
      </section>
    </body>
    """
  end

  @impl true
  def mount(socket) do
    { :ok,
    socket
    |> assign(:image, "")}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> maybe_screenshot()

    {:ok, socket}
  end

  def maybe_screenshot(socket = %{assigns: %{object: %{screenshot: nil}}}) do
    assign(socket, :image, "")
  end
  def maybe_screenshot(socket = %{assigns: %{object: %{screenshot: %{file: file}}}}) do
    image = content_tag(:img, "", [
      src: @hard_coded_path_hack <> Routes.static_path(socket, "/images/" <> file.filename),
      width: 250
    ])
    assign(socket, :image, image)
  end

end

defmodule UserDocsWeb.ComposableBreadCrumb do
  import PhoenixSlime, only: [ sigil_L: 2 ]

  def render(assigns) do
    IO.inspect(assigns)
    ~L"""
    nav.breadcrumb aria-label="breadcrumbs"
      ul
        li
          = Phoenix.HTML.Link.link "Home", to: "/"
        = for item <- @items do
          li
            = Phoenix.HTML.Link.link item.name, to: item.to
        li.is-active
          = Phoenix.LiveView.Helpers.live_patch to: @last_item.to, aria_current: "page" do
            = @last_item.name
    """
  end
end

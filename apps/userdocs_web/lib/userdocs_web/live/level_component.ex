defmodule UserDocsWeb.LevelComponent do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <nav class="level"></nav>
    """
  end
end

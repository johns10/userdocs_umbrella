defmodule UserDocsWeb.Layout do
  use Phoenix.HTML

  def is_hidden?(%{expanded: false}), do: " is-hidden"
  def is_hidden?(%{expanded: true}), do: ""
end

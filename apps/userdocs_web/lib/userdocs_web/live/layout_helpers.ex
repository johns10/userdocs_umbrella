defmodule UserDocsWeb.Layout do
  use Phoenix.HTML

  def is_hidden?(%{expanded: false}), do: " is-hidden"
  def is_hidden?(%{expanded: true}), do: ""
  def is_hidden?(%{action: :new}), do: ""
  def is_hidden?(%{action: :show}), do: " is-hidden"
end

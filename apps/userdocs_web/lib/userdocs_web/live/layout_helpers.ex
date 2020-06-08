defmodule UserDocsWeb.Layout do
  use Phoenix.HTML

  @doc """
  
  """
  def content_group(group_label, contents) do
    [
      content_tag(:h3, []) do 
        group_label 
      end,
      content_tag(:dl, []) do
        contents
      end
    ]
  end

  def content_item(contents) do
    content_tag(:dt, []) do
      contents
    end
  end
  
end
  
defmodule UserDocs.Web.Element.ChangeHandler do

  require Logger

  def execute(element, state) do
    IO.puts("No changes we need to respond to on the element form")
    %{
      element: state.current_object.element
    }
  end

end

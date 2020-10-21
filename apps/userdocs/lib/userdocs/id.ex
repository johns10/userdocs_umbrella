defmodule UserDocs.ID do
  def temp_id() do
    UUID.uuid4()
  end
end

defmodule UserDocsWeb.API.Resolvers.Process do

  alias UserDocs.Automation.Process
  alias UserDocs.Automation.Step

  def get_process!(%Step{ process: %Process{} = process }, _args, _resolution) do
    IO.puts("Get process call where the parent is step, and it has a preloaded process")
    { :ok, process }
  end
  def get_process!(%Step{ process: nil, process_id: nil }, _args, _resolution) do
    IO.puts("Get process call where the parent is step, and the eprocess_id is nil")
    { :ok, nil }
  end

end

defmodule UserDocsWeb.ElectronWebDriver.ProcessInstance do
  alias UserDocs.AutomationManager
  alias UserDocs.Jobs
  alias UserDocs.Jobs.ProcessInstance

  def execute(socket, process_id, order) when is_integer(process_id) do
    IO.inspect("Electron Webdriver Executing Process")
    { :ok, process_instance } =
      AutomationManager.get_process!(process_id)
      |> Jobs.create_process_instance_from_process(order + 1)

    socket
    |> execute(process_instance)
  end

  def execute(socket, %ProcessInstance{} = process_instance) do
    formatted_process_instance = Jobs.format_process_instance_for_export(process_instance)
    IO.inspect(formatted_process_instance)
    socket
    |> Phoenix.LiveView.push_event("execute-process", %{ data: formatted_process_instance })
  end
end

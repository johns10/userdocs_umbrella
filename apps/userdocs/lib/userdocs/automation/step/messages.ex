defmodule UserDocs.Automation.Step.Messages do

  alias UserDocs.Automation.Step
  alias UserDocs.Helpers

  def new_modal_menu(socket, params) do
    required_keys = [ :processes, :process_id, :step_types, :annotation_types, :process, :state_opts ]
    params = Helpers.validate_params(params, required_keys, __MODULE__)

    %{ target: "ModalMenus" }
    |> init(socket, params.processes, params.process_id, params.step_types, params.annotation_types)
    |> new(socket, params.process)
  end

  defp new(message, _socket, process) do
    message
    |> Map.put(:object, %Step{})
    |> Map.put(:action, :new)
    |> Map.put(:title, "New Step")
    |> Map.put(:parent, process)
  end

  defp init(message, _socket, processes, process_id, step_types, annotation_types) do
    select_lists = %{
      processes: Helpers.select_list(processes, :name, false),
      step_types: Helpers.select_list(step_types, :name, false)
    }

    data = %{
      step_types: step_types,
      annotation_types: annotation_types
    }

    message
    |> Map.put(:type, :step)
    |> Map.put(:parent_id, process_id)
    |> Map.put(:select_lists, select_lists)
    |> Map.put(:data, data)
  end
end

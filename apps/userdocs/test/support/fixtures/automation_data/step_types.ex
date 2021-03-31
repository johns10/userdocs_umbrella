defmodule UserDocs.AutomationFixtures.StepTypes do
  def data() do
    [
      %{
        args: ["url", "page_id", "page_reference"],
        name: "Navigate"
      },
      %{
        args: ["element_id"],
        name: "Wait"
      },
      %{
        args: ["element_id"],
        name: "Click"
      },
      %{
        args: ["element_id", "text"],
        name: "Fill Field"
      },
      %{
        args: ["annotation_id", "element_id"],
        name: "Apply Annotation"
      },
      %{
        args: ["width", "height"],
        name: "Set Size Explicit"
      },
      %{
        args: [],
        name: "Full Screen Screenshot"
      },
      %{
        args: [],
        name: "Clear Annotations"
      },
      %{
        args: ["element_id"],
        name: "Element Screenshot"
      }
    ]
  end
end

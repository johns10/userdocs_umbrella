defmodule UserDocs.AutomationFixtures.StepTypes do
  def data() do
    [
      %{
        args: ["page_form"],
        name: "Navigate"
      },
      %{
        args: ["element_id", "element_form"],
        name: "Wait for Element"
      },
      %{
        args: ["element_id", "element_form"],
        name: "Click"
      },
      %{
        args: ["element_id", "element_form", "text"],
        name: "Fill Field"
      },
      %{
        args: ["annotation_id", "annotation_form", "element_id", "element_form"],
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
        args: ["element_id", "element_form"],
        name: "Element Screenshot"
      },
      %{ args: ["element_id", "element_form"], name: "Scroll to Element" },
      %{ args: ["element_id", "element_form"], name: "Send Enter Key" },
      %{
        args: ["element_id", "element_form"],
        name: "Submit Form"
      },
    ]
  end
end

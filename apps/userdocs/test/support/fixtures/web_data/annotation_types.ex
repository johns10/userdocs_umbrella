defmodule UserDocs.WebFixtures.AnnotationTypes do
  def data() do
    [
      _outline = %{
        args: ["color", "thickness"],
        name: "Outline"
      },
      _blur = %{
        args: ["color", "thickness"],
        name: "Blur"
      },
      _badge = %{
        args: ["x_orientation", "y_orientation", "size", "label", "color", "x_offset", "y_offset", "font_size"],
        name: "Badge"
      },
      _badge_blur = %{
        args: ["x_orientation", "y_orientation", "size", "label", "color",
         "x_offset", "y_offset", "font_size"],
        name: "Badge Blur"
      },
      _badge_outline = %{
        args: ["x_orientation", "y_orientation", "size", "label", "color",
         "thickness", "x_offset", "y_offset", "font_size"],
        name: "Badge Outline"
      }
    ]
  end
end

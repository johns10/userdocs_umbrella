defmodule UserDocs.StateFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.DocumentVersionFixtures
  alias UserDocs.UsersFixtures
  alias UserDocs.MediaFixtures
  alias UserDocs.WebFixtures
  alias UserDocs.AutomationFixtures

  def state() do
    user = UsersFixtures.user()
    team = UsersFixtures.team()
    team_user = UsersFixtures.team_user(user.id, team.id)
    content_one =  DocumentVersionFixtures.content(team)
    content_two = DocumentVersionFixtures.content(team)
    content_three = DocumentVersionFixtures.content(team)
    file_one = MediaFixtures.file()
    file_two = MediaFixtures.file()
    file_three = MediaFixtures.file()
    file_four = MediaFixtures.file()
    badge_annotation_type = WebFixtures.annotation_type(:badge)
    outline_annotation_type = WebFixtures.annotation_type(:outline)
    page = WebFixtures.page()

    annotation_one =
      WebFixtures.annotation(page)
      |> Map.put(:annotation_type_id, badge_annotation_type.id)
      |> Map.put(:annotation_type, badge_annotation_type)

    annotation_two =
      WebFixtures.annotation(page)
      |> Map.put(:annotation_type_id, outline_annotation_type.id)
      |> Map.put(:annotation_type, outline_annotation_type)

    strategy = WebFixtures.strategy()

    element_one =
      WebFixtures.element(page, strategy)
      |> Map.put(:strategy, strategy)

    element_two =
      WebFixtures.element(page, strategy)
      |> Map.put(:strategy, strategy)

    empty_step =
      AutomationFixtures.step()
      |> Map.put(:annotation, nil)
      |> Map.put(:element, nil)

    step_with_annotation =
      AutomationFixtures.step()
      |> Map.put(:annotation_id, annotation_one.id)
      |> Map.put(:annotation, annotation_one)
      |> Map.put(:element, nil)

    step_with_element =
      AutomationFixtures.step()
      |> Map.put(:element_id, element_two.id)
      |> Map.put(:element, element_two)
      |> Map.put(:annotation, nil)

    step_with_both =
      AutomationFixtures.step()
      |> Map.put(:element_id, element_two.id)
      |> Map.put(:element, element_two)
      |> Map.put(:annotation_id, annotation_one.id)
      |> Map.put(:annotation, annotation_one)

    %{
      data: %{
        users: [ user ],
        teams: [ team ],
        team_users: [ team_user ],
        files: [ file_one, file_two, file_three, file_four ],
        content: [ content_one, content_two, content_three ],
        steps: [empty_step, step_with_annotation, step_with_element, step_with_both],
        annotations: [ annotation_one, annotation_two ],
        elements: [ element_one, element_two ],
        strategies: [ strategy ],
        annotation_types: [badge_annotation_type, outline_annotation_type]
      }
    }
  end

end

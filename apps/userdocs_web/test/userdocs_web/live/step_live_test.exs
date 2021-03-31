defmodule UserDocsWeb.StepLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Users
  alias UserDocs.Web
  alias UserDocs.Automation
  alias UserDocs.AutomationFixtures
  alias UserDocs.UsersFixtures
  alias UserDocs.Projects
  alias UserDocs.ProjectsFixtures
  alias UserDocs.WebFixtures

  @process_attrs %{name: "valid_process"}

  @create_attrs %{order: 42}
  @update_attrs %{order: 43}
  @invalid_attrs %{ order: nil}

  defp invalid_attrs(process_id) do
    %{
      order: nil,
      process_id: process_id
    }
  end

  defp valid_attrs(process_id, step_type_id) do
    %{
      order: 1,
      process_id: process_id,
      step_type_id: step_type_id
    }
  end

  defp fixture(:user), do: UsersFixtures.user()
  defp first_user(), do: Users.list_users() |> Enum.at(0)
  defp first_user_id(), do: first_user() |> Map.get(:id)
  defp create_user(_), do: %{user: fixture(:user)}

  defp fixture(:team) , do: UsersFixtures.team()
  defp first_team_id(), do: Users.list_teams() |> Enum.at(0) |> Map.get(:id)
  defp create_team(_), do: %{team: fixture(:team)}

  defp fixture(:team_user), do: UsersFixtures.team_user(first_user_id(), first_team_id())
  defp create_team_user(_), do: %{team_user: fixture(:team_user)}

  defp fixture(:project), do: ProjectsFixtures.project(first_team_id())
  defp first_project_id(), do: Projects.list_projects() |> Enum.at(0) |> Map.get(:id)
  defp create_project(_), do: %{project: fixture(:project)}

  defp fixture(:version), do: ProjectsFixtures.version(first_project_id())
  defp first_version_id(), do: Projects.list_versions() |> Enum.at(0) |> Map.get(:id)
  defp create_version(_), do: %{version: fixture(:version)}

  defp fixture(:process), do: AutomationFixtures.process(first_version_id)
  defp first_process_id(), do: Automation.list_processes() |> Enum.at(0) |> Map.get(:id)
  defp create_process(_), do: %{process: fixture(:process)}

  defp fixture(:page), do: WebFixtures.page(first_version_id)
  defp first_page(), do: Web.list_pages() |> Enum.at(0)
  defp first_page_id(), do: first_page() |> Map.get(:id)
  defp second_page(), do: Web.list_pages() |> Enum.at(1)
  defp second_page_id(), do: second_page() |> Map.get(:id)
  defp create_page(_), do: %{page: fixture(:page)}

  defp fixture(:strategy), do: WebFixtures.strategy()
  defp first_strategy_id(), do: Web.list_strategies() |> Enum.at(0) |> Map.get(:id)
  defp create_strategy(_), do: %{strategy: fixture(:strategy)}

  defp fixture(:element), do: WebFixtures.element(first_page_id(), first_strategy_id())
  defp first_element(), do: Web.list_elements() |> Enum.at(0)
  defp first_element_id(), do: first_element() |> Map.get(:id)
  defp second_element(), do: Web.list_elements() |> Enum.at(1)
  defp second_element_id(), do: second_element() |> Map.get(:id)
  defp create_element(_), do: %{element: fixture(:element)}

  defp fixture(:annotation), do: WebFixtures.annotation(first_page_id())
  defp first_annotation(), do: Web.list_annotations() |> Enum.at(0)
  defp first_annotation_id(), do: first_annotation() |> Map.get(:id)
  defp second_annotation(), do: Web.list_annotations() |> Enum.at(1)
  defp second_annotation_id(), do: second_annotation() |> Map.get(:id)
  defp create_annotation(_), do: %{annotation: fixture(:annotation)}

  defp fixture(:step_type), do: AutomationFixtures.step_type()
  defp fixture(:step_types), do: AutomationFixtures.all_valid_step_types()
  defp first_step_type_id(), do: Automation.list_step_types() |> Enum.at(0) |> Map.get(:id)
  defp create_step_type(_), do: %{step_type: fixture(:step_type)}
  defp create_step_types(_), do: %{step_types: fixture(:step_types)}

  defp fixture(:step), do: AutomationFixtures.step(first_page_id(), first_process_id(), first_element_id(), first_annotation_id(), first_step_type_id())
  defp first_step_id(), do: Automation.list_steps() |> Enum.at(0) |> Map.get(:id)
  defp create_step(_), do: %{step: fixture(:step)}

  defp make_selections(_) do
    user = first_user()
    { :ok, user } = Users.update_user_selections(user, %{
      selected_team_id: first_team_id(),
      selected_project_id: first_project_id(),
      selected_version_id: first_version_id()
    })
    %{user: user}
  end

  defp setup_session(%{ conn: conn }) do
    conn = Plug.Test.init_test_session(conn, %{})
    opts = Pow.Plug.Session.init(otp_app: :userdocs_web)
    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> Pow.Plug.Session.call(opts)
      |> Pow.Plug.Session.do_create(first_user(), opts)

    :timer.sleep(100)

    %{ conn: conn }
  end

  defp step_type_from_name(step_types, name) do
    step_types
    |> Enum.filter(fn(st) -> st.name == name end)
    |> Enum.at(0)
  end

  describe "Index" do
    setup [
      :create_user,
      :create_team,
      :create_team_user,
      :create_project,
      :create_version,
      :create_process,
      :create_page,
      :create_page,
      :create_strategy,
      :create_element,
      :create_element,
      :create_annotation,
      :create_annotation,
      :create_step_type,
      :create_step_types,
      :create_step,
      :make_selections,
      :setup_session
    ]

    test "lists all steps", %{conn: conn} do
      {:ok, index_live, html} = live(conn, Routes.step_index_path(conn, :index, first_process_id()))

      assert html =~ "Steps"
    end

    test "saves new step", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :index, first_process_id()))

      assert index_live
      |> element("a", "New Step")
      |> render_click() =~ "New Step"

      assert_patch(index_live, Routes.step_index_path(conn, :new, first_process_id()))

      assert index_live
      |> form("#step-form", step: invalid_attrs(first_process_id()))
      |> render_change() =~ "can&apos;t be blank"

      step_attrs = valid_attrs(first_process_id(), first_step_type_id())

      {:ok, _, html} =
        index_live
        |> form("#step-form", step: step_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.step_index_path(conn, :index, first_process_id()))

      assert html =~ "Step created successfully"
    end

    test "updates step in listing", %{conn: conn, step: step} do
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :index, first_process_id()))

      assert index_live
             |> element("#edit-step-"<> Integer.to_string(step.id))
             |> render_click() =~ "Edit Step"

      assert_patch(index_live, Routes.step_index_path(conn, :edit, step))

      assert index_live
             |> form("#step-form", step: invalid_attrs(first_process_id()))
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#step-form", step: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.step_index_path(conn, :index, first_process_id()))

      assert html =~ "Step updated successfully"
    end

    test "changing the page_id updates the form", %{conn: conn, step: step, step_types: step_types} do
      step_type = step_type_from_name(step_types, "Navigate")
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :edit, step))
      attrs =
        valid_attrs(step.process_id, step_type.id)
        |> Map.put(:page_id, first_page().id)

      # put it in page mode
      index_live
      |> form("#step-form", step: attrs)
      |> render_change(%{ "step" => %{"page_reference" => "page"} } )

      assert index_live
             |> element("#step-" <> (step.id |> to_string) <> "-page_id")
             |> has_element?()

      assert index_live
             |> element("#page_name")
             |> render() =~ first_page().name

      # change the page
      index_live
      |> form("#step-form", step: attrs)
      |> render_change(%{ "step" => %{ "page_id" => second_page().id |> to_string() } } )

      assert index_live
             |> element("#page_name")
             |> render() =~ second_page().name

      # change it back to the first page
      index_live
      |> form("#step-form", step: attrs)
      |> render_change(%{ "step" => %{ "page_id" => first_page().id |> to_string() } } )

      assert index_live
             |> element("#page_name")
             |> render() =~ first_page().name

      # put some new text on the page
      index_live
      |> form("#step-form", step: attrs)
      |> render_change(%{ "step" => %{ "name" => "value" } } )

      assert index_live
             |> form("#step-form", step: attrs)
             |> render_submit()
             |> follow_redirect(conn, Routes.step_index_path(conn, :index, first_process_id()))
    end

    test "changing the annotation_id updates the form", %{conn: conn, step: step, step_type: step_type, step_types: step_types} do
      aa_step_type = step_type_from_name(step_types, "Apply Annotation")
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :edit, step))
      attrs = valid_attrs(step.process_id, step_type.id)

      changes = %{
        "step_type_id" => aa_step_type.id |> to_string(),
        "annotation_id" => second_annotation().id |> to_string(),
        "element_id" => second_element().id |> to_string()
      }

      # change the annotation_id
      index_live
      |> form("#step-form", step: attrs)
      |> render_change(%{ "step" => changes })

      # Annotation form changes
      assert index_live
             |> element("#annotation-" <> (first_annotation().id |> to_string) <> "-label")
             |> render() =~ second_annotation().label

      # change it back
      index_live
      |> form("#step-form", step: attrs)
      |> render_change(%{ "step" => %{ "step_type_id" => aa_step_type.id |> to_string(), "annotation_id" => (first_annotation().id |> to_string()) } })

      # Annotation form changes
      assert index_live
            |> element("#annotation-" <> (first_annotation().id |> to_string) <> "-label")
            |> render() =~ first_annotation().label

      # Element picker doesn't
      assert index_live
             |> element("#step-" <> (step.id |> to_string) <> "-element_id")
             |> render() =~ "selected=\"selected\">" <> second_element().name

      # put some new text on the page, save it
      index_live
      |> form("#step-form", step: attrs)
      |> render_change(%{ "step" => %{ "annotation" => %{ "name" => "updated name" } } } )

      assert index_live
             |> form("#step-form", step: attrs)
             |> render_submit()
             |> follow_redirect(conn, Routes.step_index_path(conn, :index, first_process_id()))
    end

    test "changing the element_id updates the form", %{conn: conn, step: step, step_type: step_type, step_types: step_types} do
      step_type = step_type_from_name(step_types, "Apply Annotation")
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :edit, step))
      attrs = valid_attrs(step.process_id, step_type.id)

      changes = %{
        "step_type_id" => step_type.id |> to_string(),
        "annotation_id" => second_annotation().id |> to_string(),
        "element_id" => second_element().id |> to_string()
      }

      # change the element_id
      index_live
      |> form("#step-form", step: attrs)
      |> render_change(%{ "step" => changes })

      assert index_live
             |> element("#step-" <> (step.id |> to_string) <> "-element-" <> (first_element().id |> to_string) <> "-name")
             |> render() =~ second_element().name

      # change it back
      index_live
      |> form("#step-form", step: attrs)
      |> render_change(%{ "step" => %{
          "step_type_id" => step_type.id |> to_string(),
          "element_id" => first_element().id |> to_string()
        }})

      # Element Form Changes
      assert index_live
             |> element("#step-" <> (step.id |> to_string) <> "-element-" <> (first_element().id |> to_string) <> "-name")
             |> render() =~ first_element().name

      # Annotation picker doesn't
      assert index_live
            |> element("#step-" <> (step.id |> to_string) <> "-annotation_id")
            |> render() =~ "selected=\"selected\">" <> second_annotation().name

      # put some new text on the page, save it
      index_live
      |> form("#step-form", step: attrs)
      |> render_change(%{ "step" => %{ "element" => %{ "name" => "updated name" } } } )

      assert index_live
            |> form("#step-form", step: attrs)
            |> render_submit()
            |> follow_redirect(conn, Routes.step_index_path(conn, :index, first_process_id()))
    end

    test "deletes step in listing", %{conn: conn, step: step} do
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :index, first_process_id()))

      assert index_live
             |> element("#delete-step-"<> Integer.to_string(step.id))
             |> render_click()

      :timer.sleep(100) # Racy cause subscriptions

      refute has_element?(index_live, "#delete-step-"<> Integer.to_string(step.id))
    end
  end
end

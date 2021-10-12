defmodule UserDocsWeb.StepLiveTest do
  use UserDocsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias UserDocs.Web
  alias UserDocs.AutomationFixtures
  alias UserDocs.UsersFixtures
  alias UserDocs.ProjectsFixtures
  alias UserDocs.WebFixtures

  #@chrome "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe"
  #|> open_browser(&(System.cmd("C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe", [&1])))

  defp invalid_attrs(process_id) do
    %{
      order: "",
      step_type_id: nil,
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

  defp create_password(_), do: %{password: UUID.uuid4()}
  defp create_user(%{password: password}), do: %{user: UsersFixtures.confirmed_user(password)}
  defp create_team(_), do: %{team: UsersFixtures.team()}
  defp create_team_user(%{user: user, team: team}), do: %{team_user: UsersFixtures.team_user(user.id, team.id)}
  defp create_strategy(_), do: %{strategy: WebFixtures.strategy()}
  defp create_project(%{team: team, strategy: strategy}), do: %{project: ProjectsFixtures.project(team.id, strategy.id)}
  defp create_process(%{project: project}), do: %{process: AutomationFixtures.process(project.id)}
  defp create_page(%{project: project}), do: %{page: WebFixtures.page(project.id)}
  defp create_element(%{page: page, strategy: strategy}), do: %{element: WebFixtures.element(page.id, strategy.id)}
  defp create_annotation(%{page: page}), do: %{annotation: WebFixtures.annotation(page.id)}
  defp create_step_type(_), do: %{step_type: AutomationFixtures.step_type()}
  defp create_step_types(_), do: %{step_types: AutomationFixtures.all_valid_step_types()}
  defp create_annotation_types(_), do: %{annotation_types: WebFixtures.all_valid_annotation_types()}
  defp create_step(%{page: page, process: p, element: e, annotation: a, step_type: st}) do
    %{step: AutomationFixtures.step(page.id, p.id, e.id, a.id, st.id)}
  end

  defp first_page(), do: Web.list_pages() |> Enum.at(0)
  defp second_page(), do: Web.list_pages() |> Enum.at(1)

  defp first_element(), do: Web.list_elements() |> Enum.at(0)
  defp second_element(), do: Web.list_elements() |> Enum.at(1)

  defp first_annotation(), do: Web.list_annotations() |> Enum.at(0)
  defp second_annotation(), do: Web.list_annotations() |> Enum.at(1)

  defp make_selections(%{user: user, team: team, project: project}) do
    {:ok, user} = UserDocs.Users.update_user_selections(user, %{
      selected_team_id: team.id,
      selected_project_id: project.id
    })
    %{user: user}
  end

  @default_opts [
    otp_app: :userdocs_web,
    web_module: UserDocsWeb,
    user: UserDocs.Users.User,
    repo: UserDocs.Repo,
    cache_store_backend: Pow.Store.Backend.MnesiaCache,
    backend: Pow.Store.Backend.MnesiaCache,
    routes_backend: UserDocsWeb.Pow.Routes
  ]

  defp setup_session(%{conn: conn, user: user}) do
    opts = Pow.Plug.Session.init(@default_opts)
    conn =
      conn
      |> Plug.Test.init_test_session(%{current_user: user})
      |> Pow.Plug.Session.call(opts)
      |> Pow.Plug.Session.do_create(user, opts)

    :timer.sleep(100)

    %{conn: conn}
  end

  defp grevious_workaround(%{conn: conn, user: user, password: password}) do
    conn = post(conn, "session", %{user: %{email: user.email, password: password}})
    :timer.sleep(100)
    %{authed_conn: conn}
  end

  defp step_type_from_name(step_types, name) do
    step_types
    |> Enum.filter(fn(st) -> st.name == name end)
    |> Enum.at(0)
  end

  describe "Index" do
    setup [
      :create_password,
      :create_user,
      :create_team,
      :create_team_user,
      :create_strategy,
      :create_project,
      :create_process,
      :create_page,
      :create_page,
      :create_element,
      :create_element,
      :create_annotation,
      :create_annotation,
      :create_step_type,
      :create_step_types,
      :create_annotation_types,
      :create_step,
      :grevious_workaround,
      :make_selections,
    ]

    test "lists all steps", %{authed_conn: conn, process: process} do
      {:ok, _index_live, html} = live(conn, Routes.step_index_path(conn, :index, process.id))

      assert html =~ "Steps"
    end

    test "saves new step", %{authed_conn: conn, process: process, step_type: step_type} do
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :index, process.id))

      assert index_live
      |> element("a", "New Step")
      |> render_click() =~ "New Step"

      assert_patch(index_live, Routes.step_index_path(conn, :new, process.id))

      assert index_live
      |> form("#step-form", step_form: invalid_attrs(process.id))
      |> render_change() =~ "can&#39;t be blank"

      step_attrs = valid_attrs(process.id, step_type.id)

      {:ok, _, html} =
        index_live
        |> form("#step-form", step_form: step_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.step_index_path(conn, :index, process.id))

      assert html =~ "Step created successfully"
    end

    test "updates step in listing", %{authed_conn: conn, step: step, process: process, step_type: step_type} do
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :index, process.id))

      assert index_live
             |> element("#edit-step-"<> Integer.to_string(step.id))
             |> render_click() =~ "Edit Step"

      assert_patch(index_live, Routes.step_index_path(conn, :edit, step))

      assert index_live
             |> form("#step-form", step_form: invalid_attrs(process.id))
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#step-form", step_form: valid_attrs(step.process_id, step_type.id))
        |> render_submit()
        |> follow_redirect(conn, Routes.step_index_path(conn, :index, process.id))

      assert html =~ "Step updated successfully"
    end

    test "changing the page_id updates the form", %{authed_conn: conn, step: step, step_types: step_types, process: process} do
      step_type = step_type_from_name(step_types, "Navigate")
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :edit, step))
      attrs =
        valid_attrs(step.process_id, step_type.id)
        |> Map.put(:page_id, first_page().id)

      # put it in page mode
      index_live
      |> form("#step-form", step_form: attrs)
      |> render_change()

      assert index_live
             |> element("#step-form_page_id")
             |> has_element?()

      assert index_live
             |> element("#step-form_page_name")
             |> render() =~ first_page().name

      # change the page
      index_live
      |> form("#step-form", step_form: attrs)
      |> render_change(%{"step_form" => %{"page_id" => second_page().id |> to_string()}} )

      assert index_live
             |> element("#step-form_page_name")
             |> render() =~ second_page().name

      # change it back to the first page
      index_live
      |> form("#step-form", step_form: attrs)
      |> render_change(%{"step_form" => %{"page_id" => first_page().id |> to_string()}} )

      assert index_live
             |> element("#step-form_page_name")
             |> render() =~ first_page().name

      # put some new text on the page
      index_live
      |> form("#step-form", step_form: attrs)
      |> render_change(%{"step_form" => %{"name" => "value"}} )

      assert index_live
             |> form("#step-form", step_form: attrs)
             |> render_submit()
             |> follow_redirect(conn, Routes.step_index_path(conn, :index, process.id))
    end

    test "changing the annotation_id updates the form", %{authed_conn: conn, step: step, step_types: step_types, process: process, element: element, annotation: annotation, page: page} do
      aa_step_type = step_type_from_name(step_types, "Apply Annotation")
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :edit, step))
      attrs =
        AutomationFixtures.step_attrs(:valid, page.id, process.id, element.id, annotation.id, aa_step_type.id)
        |> Map.delete(:annotation_id)
        |> Map.delete(:element_id)
        |> Map.delete(:name)
        |> Map.delete(:margin_all)
        |> Map.delete(:margin_top)
        |> Map.delete(:margin_left)
        |> Map.delete(:margin_right)
        |> Map.delete(:margin_bottom)

      changes = %{"step_type_id" => aa_step_type.id |> to_string()}

      index_live
      |> form("#step-form", step_form: attrs)
      |> render_change(%{"step_form" => changes})

      changes = %{"annotation_id" => second_annotation().id |> to_string()}

      # change the annotation_id
      index_live
      |> form("#step-form", step_form: attrs)
      |> render_change(%{"step_form" => changes})

      # Annotation form changes
      assert index_live
      |> element("#step-form_annotation_id")
      |> render() =~ second_annotation().name

      second_changes = %{"annotation_id" => first_annotation().id |> to_string()}

      # change it back
      index_live
      |> form("#step-form", step_form: attrs)
      |> render_change(%{"step_form" => second_changes})

      # Annotation form changes
      assert index_live
      |> element("#step-form_annotation_id")
      |> render() =~ first_annotation().name

      # Element picker doesn't
      assert index_live |> render() =~ "selected=\"selected\">" <> second_element().name

      # put some new text on the page, save it
      index_live
      |> form("#step-form", step_form: attrs)
      |> render_change(%{"step_form" => %{"annotation" => %{"name" => "updated name"}}} )

      assert index_live
             |> form("#step-form", step_form: attrs)
             |> render_submit()
             |> follow_redirect(conn, Routes.step_index_path(conn, :index, process.id))
    end

    test "changing the element_id updates the form", %{authed_conn: conn, step: step, step_types: step_types, process: process} do
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
      |> form("#step-form", step_form: attrs)
      |> render_change(%{"step_form" => changes})

      assert index_live
      |> element("#step-form_element_name")
      |> render() =~ second_element().name

      # change it back
      index_live
      |> form("#step-form", step_form: attrs)
      |> render_change(%{"step_form" => %{
          "step_type_id" => step_type.id |> to_string(),
          "element_id" => first_element().id |> to_string()
        }})

      # Element Form Changes
      assert index_live
      |> element("#step-form_element_name")
      |> render() =~ first_element().name

      # Annotation picker doesn't
      assert index_live
            |> element("#step-form_annotation_id")
            |> render() =~ "selected=\"selected\">" <> second_annotation().name

      # put some new text on the page, save it
      index_live
      |> form("#step-form", step_form: attrs)
      |> render_change(%{"step_form" => %{"element" => %{"name" => "updated name"}}} )

      assert index_live
            |> form("#step-form", step_form: attrs)
            |> render_submit()
            |> follow_redirect(conn, Routes.step_index_path(conn, :index, process.id))
    end

    test "deletes step in listing", %{authed_conn: conn, step: step, process: process} do
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :index, process.id))

      assert index_live
             |> element("#delete-step-"<> Integer.to_string(step.id))
             |> render_click()

      :timer.sleep(100) # Racy cause subscriptions

      refute has_element?(index_live, "#delete-step-"<> Integer.to_string(step.id))
    end

    test "click event opens form, filling additional fields and saving works", %{authed_conn: conn, process: process, step: step, step_types: step_types, user: user, page: page} do
      step_type = step_type_from_name(step_types, "Click")
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :index, process.id))
      attrs =
        valid_attrs(step.process_id, step_type.id)
        |> Map.put(:page_id, first_page().id)
        |> Map.delete(:step_type_id)

      event = %{
        "action" => "Click",
        "selector" => "test_selector",
        "href" => page.url,
        "element_name" => "Hi",
        "order" => "1"
      }

      # Pass the click browser event
      UserDocsWeb.Endpoint.broadcast("user:" <> to_string(user.id), "event:browser_event", event)
      #send(index_live.pid, %{topic: "user:" <> to_string(user.id), event: "event:browser_event", payload: event})
      html = render(index_live)
      assert html =~ "Click"
      assert html =~ event["selector"]

      # Create and put the changes required to make the form valid (page will be passed in production)
      changes = %{
        "step_form" => %{
          "order" => attrs.order |> to_string(),
          "page_id" => attrs.page_id |> to_string(),
          "element" => %{
            "name" => "test_element_name",
            "page_id" => attrs.page_id |> to_string()
          }
        }
      }

      index_live
      |> form("#step-form", step_form: attrs)
      |> render_change(changes)

      # Save the form
      {:ok, _, html} =
        index_live
        |> form("#step-form", step_form: attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.step_index_path(conn, :index, process.id))

      assert html =~ "Step created successfully"
    end

    test "navigate event opens form, filling additional fields and saving works", %{authed_conn: conn, process: process, step: step, step_types: step_types, user: user} do
      step_type = step_type_from_name(step_types, "Navigate")
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :index, process.id))
      attrs =
        valid_attrs(step.process_id, step_type.id)
        |> Map.delete(:step_type_id)

      event = %{
        "action" => "Navigate",
        "href" => "https://www.google.com",
        "page_title" => "Page",
        "order" => "5"
      }

      # Pass the navigate browser event
      UserDocsWeb.Endpoint.broadcast("user:" <> to_string(user.id), "event:browser_event", event)
      html = render(index_live)
      assert html =~ "Navigate"
      assert html =~ event["href"]

      # Create and put the changes required to make the form valid
      changes = %{
        "step_form" => %{
          "order" => attrs.order |> to_string(),
          "page" => %{
            "name" => "test_page_name"
          }
        }
      }

      index_live
      |> form("#step-form", step_form: attrs)
      |> render_change(changes)

      # Save the form
      {:ok, _, html} =
        index_live
        |> form("#step-form", step_form: attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.step_index_path(conn, :index, process.id))

      assert html =~ "Step created successfully"
    end

    test "Click, then navigate does the expected thing", %{authed_conn: conn, process: process, step: step, step_types: step_types, user: user, page: page} do
      step_type = step_type_from_name(step_types, "Click")
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :index, process.id))
      attrs =
        valid_attrs(step.process_id, step_type.id)
        |> Map.put(:page_id, first_page().id)
        |> Map.delete(:step_type_id)

      event = %{
        "action" => "Click",
        "selector" => "test_selector",
        "href" => page.url,
        "element_name" => "Hi",
        "order" => "1"
      }

      # Pass the click browser event
      UserDocsWeb.Endpoint.broadcast("user:" <> to_string(user.id), "event:browser_event", event)
      html = render(index_live)
      assert html =~ "Click"
      assert html =~ event["selector"]

      event = %{
        "action" => "Navigate",
        "href" => "https://www.google.com",
        "page_title" => "Page",
        "order" => "5"
      }

      # Pass the navigate browser event
      UserDocsWeb.Endpoint.broadcast("user:" <> to_string(user.id), "event:browser_event", event)
      html = render(index_live)
      assert index_live |> element("#step-form_step_type_id") |> render()  =~ "Navigate"
      assert index_live |> element("#step-form_page_url") |> render()  =~ event["href"]

      # Create and put the changes required to make the form valid
      changes = %{
        "step_form" => %{
          "order" => attrs.order |> to_string(),
          "page" => %{
            "name" => "test_page_name"
          }
        }
      }

      # This could spell trouble, add the additional fields and save
      attrs = Map.delete(attrs, :page_id)
      index_live
      |> form("#step-form", step_form: attrs)
      |> render_change(changes)

      # Save the form
      {:ok, _, html} =
        index_live
        |> form("#step-form", step_form: attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.step_index_path(conn, :index, process.id))

      assert html =~ "Step created successfully"
    end

    test "Apply Annotation event opens form, filling additional fields and saving works", %{authed_conn: conn, process: process, step_types: step_types, annotation: annotation, element: element, page: page, user: user} do
      aa_step_type = step_type_from_name(step_types, "Apply Annotation")
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :index, process.id))
      _attrs =
        AutomationFixtures.step_attrs(:valid, page.id, process.id, element.id, annotation.id, aa_step_type.id)
        |> Map.delete(:annotation_id)
        |> Map.delete(:element_id)
        |> Map.delete(:name)

      event = %{
        "action" => "Apply Annotation",
        "selector" => "test_selector",
        "annotation_type" => "Badge",
        "href" => page.url,
        "element_name" => "Name",
        "order" => "1",
        "label" => "1"
      }

      # Pass the navigate browser event
      UserDocsWeb.Endpoint.broadcast("user:" <> to_string(user.id), "event:browser_event", event)
      html = render(index_live)
      assert html =~ "Apply Annotation"
      assert html =~ event["selector"]
    end

    test "index handles standard events", %{authed_conn: conn, project: project} do
      {:ok, live, _html} = live(conn, Routes.user_index_path(conn, :index))
      send(live.pid, {:broadcast, "update", %UserDocs.Users.User{}})
      assert live
             |> element("#project-picker-" <> to_string(project.id))
             |> render_click() =~ project.name
    end

    test "browser events update the Edit form", %{authed_conn: conn, step: step, step_types: step_types, process: process, element: element, annotation: annotation, page: page, user: user} do
      aa_step_type = step_type_from_name(step_types, "Apply Annotation")
      {:ok, index_live, _html} = live(conn, Routes.step_index_path(conn, :edit, step))
      attrs =
        AutomationFixtures.step_attrs(:valid, page.id, process.id, element.id, annotation.id, aa_step_type.id)
        |> Map.delete(:annotation_id)
        |> Map.delete(:element_id)
        |> Map.delete(:name)
        |> Map.delete(:margin_all)
        |> Map.delete(:margin_top)
        |> Map.delete(:margin_left)
        |> Map.delete(:margin_right)
        |> Map.delete(:margin_bottom)

      changes = %{"step_type_id" => aa_step_type.id |> to_string()}

      index_live
      |> form("#step-form", step_form: attrs)
      |> render_change(%{"step" => changes})

      event = %{
        "action" => "Click",
        "selector" => "test_selector",
        "href" => page.url,
        "element_name" => "Hi",
        "order" => "1"
      }

      # Pass the click browser event
      UserDocsWeb.Endpoint.broadcast("user:" <> to_string(user.id), "event:browser_event", event)
      :timer.sleep(100)

      assert index_live |> element("#step-form_step_type_id") |> render() =~ "selected=\"selected\">Click"
      assert index_live |> element("#step-form_element_selector") |> render() =~ event["selector"]
    end

  end
end

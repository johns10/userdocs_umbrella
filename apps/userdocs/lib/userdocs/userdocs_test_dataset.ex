defmodule UserDocs.TestDataset do

  alias UserDocs.Users
  alias UserDocs.Users.User
  alias UserDocs.Users.Team
  alias UserDocs.Users.TeamUser

  alias UserDocs.Projects
  alias UserDocs.Projects.Project
  alias UserDocs.Projects.Version

  alias UserDocs.Documents
  alias UserDocs.Documents.DocumentVersion
  alias UserDocs.Documents.Content
  alias UserDocs.Documents.ContentVersion
  alias UserDocs.Documents.LanguageCode

  alias UserDocs.Web
  alias UserDocs.Web.Page
  alias UserDocs.Web.AnnotationType
  alias UserDocs.Web.Annotation
  alias UserDocs.Web.Element
  alias UserDocs.Web.Strategy

  alias UserDocs.Automation
  alias UserDocs.Automation.Step
  alias UserDocs.Automation.StepType
  alias UserDocs.Automation.Process

  alias UserDocs.Media.File
  alias UserDocs.Media.Screenshot

  alias UserDocs.Repo

  def delete() do
    Repo.delete_all(Screenshot)
    Repo.delete_all(File)
    Repo.delete_all(ContentVersion)
    Repo.delete_all(Step)
    Repo.delete_all(Process)
    Repo.delete_all(DocumentVersion)
    Repo.delete_all(Document)
    Repo.delete_all(Annotation)
    Repo.delete_all(Element)
    Repo.delete_all(Page)
    Repo.delete_all(Version)
    Repo.delete_all(Project)
    Repo.delete_all(Step)
    Repo.delete_all(Annotation)
    Repo.delete_all(AnnotationType)
    Repo.delete_all(Strategy)
    Repo.delete_all(Content)
    Repo.delete_all(TeamUser)
    Enum.each(Users.list_teams, fn(t) -> Users.delete_team(t) end)
    Enum.each(Users.list_users, fn(u) -> Users.delete_user(u) end)
  end

  def create() do

  strategies = [
    xpath_strategy = %{
      name: "xpath"
    },
    css_strategy = %{
      name: "css"
    }
  ]

  {:ok, %Strategy{id: xpath_strategy_id}} =
    %Strategy{}
    |> Strategy.changeset(xpath_strategy)
    |> Repo.insert()

    {:ok, %Strategy{id: css_strategy_id}} =
      %Strategy{}
      |> Strategy.changeset(css_strategy)
      |> Repo.insert()

  # Annotation_types

  _annotation_types = [
    outline = %{
      args: ["color", "thickness"],
      name: "Outline"
    },
    blur = %{
      args: ["color", "thickness"],
      name: "Blur"
    },
    badge = %{
      args: ["x_orientation", "y_orientation", "size", "label", "color", "x_offset", "y_offset", "font_size"],
      name: "Badge"
    },
    badge_blur = %{
      args: ["x_orientation", "y_orientation", "size", "label", "color",
       "x_offset", "y_offset", "font_size"],
      name: "Badge Blur"
    },
    badge_outline = %{
      args: ["x_orientation", "y_orientation", "size", "label", "color",
       "thickness", "x_offset", "y_offset", "font_size"],
      name: "Badge Outline"
    }
  ]

  {:ok, %AnnotationType{id: outline_id}} =
    %AnnotationType{}
    |> AnnotationType.changeset(outline)
    |> Repo.insert()

  {:ok, %AnnotationType{id: _blur_id}} =
    %AnnotationType{}
    |> AnnotationType.changeset(blur)
    |> Repo.insert()

  {:ok, %AnnotationType{id: _badge_id}} =
    %AnnotationType{}
    |> AnnotationType.changeset(badge)
    |> Repo.insert()

  {:ok, %AnnotationType{id: _badge_blur_id}} =
    %AnnotationType{}
    |> AnnotationType.changeset(badge_blur)
    |> Repo.insert()

  {:ok, %AnnotationType{id: badge_outline_id}} =
    %AnnotationType{}
    |> AnnotationType.changeset(badge_outline)
    |> Repo.insert()

  # Step Types

  _step_types = [
    navigate = %{
      args: ["url", "page_id", "page_reference"],
      name: "Navigate"
    },
    wait = %{
      args: ["element_id"],
      name: "Wait"
    },
    click = %{
      args: ["element_id"],
      name: "Click"
    },
    fill_field = %{
      args: ["element_id", "text"],
      name: "Fill Field"
    },
    apply_annotation = %{
      args: ["annotation_id", "element_id"],
      name: "Apply Annotation"
    },
    set_size_explicit = %{
      args: ["width", "height"],
      name: "Set Size Explicit"
    },
    full_screen_screenshot = %{
      args: [],
      name: "Full Screen Screenshot"
    },
    clear_annotations = %{
      args: [],
      name: "Clear Annotations"
    },
    element_screenshot = %{
      args: ["element_id"],
      name: "Element Screenshot"
    }
  ]

  {:ok, %StepType{id: navigate_id}} =
    %StepType{}
    |> StepType.changeset(navigate)
    |> Repo.insert()

  {:ok, %StepType{id: _wait_id}} =
    %StepType{}
    |> StepType.changeset(wait)
    |> Repo.insert()

  {:ok, %StepType{id: click_id}} =
    %StepType{}
    |> StepType.changeset(click)
    |> Repo.insert()

  {:ok, %StepType{id: fill_field_id}} =
    %StepType{}
    |> StepType.changeset(fill_field)
    |> Repo.insert()

  {:ok, %StepType{id: apply_annotation_id}} =
    %StepType{}
    |> StepType.changeset(apply_annotation)
    |> Repo.insert()

  {:ok, %StepType{id: set_size_explicit_id}} =
    %StepType{}
    |> StepType.changeset(set_size_explicit)
    |> Repo.insert()

  {:ok, %StepType{id: full_screen_screenshot_id}} =
    %StepType{}
    |> StepType.changeset(full_screen_screenshot)
    |> Repo.insert()

  {:ok, %StepType{id: clear_annotations_id}} =
    %StepType{}
    |> StepType.changeset(clear_annotations)
    |> Repo.insert()

    {:ok, %StepType{id: element_screenshot_id}} =
      %StepType{}
      |> StepType.changeset(element_screenshot)
      |> Repo.insert()

    # User Data

    default_password = "A7B!2#x2y"

    user_1 =
      %{
        email: "johns10davenport@gmail.com",
        password: default_password,
        password_confirmation: default_password
      }

    user_2 =
      %{
        email: "johns10@gmail.com",
        password: default_password,
        password_confirmation: default_password
      }

    {:ok, user_1 = %User{id: user1_id}} =
      %User{}
      |> User.changeset(user_1)
      |> Repo.insert()

    {:ok, user_2 = %User{id: user2_id}} =
    %User{}
    |> User.changeset(user_2)
    |> Repo.insert()

    # Team Data

    funnel_cloud_team =
      %{
        name: "FunnelCloud"
      }

    loreline_team =
      %{
        name: "LoreLine"
      }

    {:ok, funnel_cloud_team = %Team{id: funnel_cloud_team_id}} =
      %Team{}
      |> Team.changeset(funnel_cloud_team)
      |> Repo.insert()

    {:ok, _loreline_team = %Team{id: loreline_team_id}} =
      %Team{}
      |> Team.changeset(loreline_team)
      |> Repo.insert()

    Users.update_user(
      user_1,
      %{ default_team_id: funnel_cloud_team_id, current_password: default_password }
    )

    Users.update_user(
      user_2,
      %{ default_team_id: funnel_cloud_team_id, current_password: default_password }
    )

    # Team Users

    team_users = [
      %{
        team_id: funnel_cloud_team_id,
        user_id: user1_id
      },
      %{
        team_id: funnel_cloud_team_id,
        user_id: user2_id
      },
      %{
        team_id: loreline_team_id,
        user_id: user1_id
      }
    ]

    Enum.map(team_users,
      fn(tu) ->
        %TeamUser{}
        |> TeamUser.changeset(tu)
        |> Repo.insert()
      end
    )

    # Projects

    funnelcloud_manager_project =
      %{
        base_url: "https://staging.app.funnelcloud.io",
        name: "FunnelCloud Manager",
        team_id: funnel_cloud_team_id
      }
    funnelcloud_operator_project =
      %{
        base_url: "https://staging.app.funnelcloud.io/#/operator",
        name: "FunnelCloud Operator",
        team_id: funnel_cloud_team_id
      }

    john_davenport_rocks_project =
      %{
        base_url: "https://www.davenport.rocks",
        name: "John Davenport Rocks",
        team_id: loreline_team_id
      }

    {:ok, funnelcloud_manager_project = %Project{id: funnelcloud_manager_project_id}} =
      %Project{}
      |> Project.changeset(funnelcloud_manager_project)
      |> Repo.insert()

    {:ok, funnelcloud_operator_project = %Project{id: _funnelcloud_operator_project_id}} =
      %Project{}
      |> Project.changeset(funnelcloud_operator_project)
      |> Repo.insert()

    {:ok, john_davenport_rocks_project = %Project{id: john_davenport_rocks_project_id}} =
      %Project{}
      |> Project.changeset(john_davenport_rocks_project)
      |> Repo.insert()


    Users.update_team(funnel_cloud_team, %{ default_project_id: funnelcloud_manager_project_id})

    # Versions

    version_2020_1 = %{
      name: "2020.2.1",
      project_id: funnelcloud_manager_project_id,
      strategy_id: css_strategy_id
    }

    version_2020_2 = %{
      name: "2020.2.2",
      project_id: funnelcloud_manager_project_id,
      strategy_id: css_strategy_id
    }

    version_1 = %{
      name: "Version 1",
      project_id: john_davenport_rocks_project_id,
      strategy_id: css_strategy_id
    }

    {:ok, _version_2020_1 = %Version{id: version_2020_1_id}} =
      %Version{}
      |> Version.changeset(version_2020_1)
      |> Repo.insert()

    {:ok, _version_2020_2 = %Version{id: version_2020_2_id}} =
      %Version{}
      |> Version.changeset(version_2020_2)
      |> Repo.insert()

    {:ok, _version_1 = %Version{id: version_1_id}} =
      %Version{}
      |> Version.changeset(version_1)
      |> Repo.insert()

    Projects.update_project(funnelcloud_manager_project, %{default_version_id: version_2020_1_id})
    Projects.update_project(funnelcloud_operator_project, %{default_version_id: version_2020_2_id})
    Projects.update_project(john_davenport_rocks_project, %{default_version_id: version_1_id})

    # Pages

    setup_page = %{
      name: "Setup",
      order: 1,
      url: "https://staging.app.funnelcloud.io/#/setup",
      version_id: version_2020_1_id
    }

    login_page = %{
      name: "Login",
      order: 2,
      url: "https://staging.app.funnelcloud.io/#/login",
      version_id: version_2020_1_id
    }

    {:ok, %Page{id: setup_page_id}} =
      %Page{}
      |> Page.changeset(setup_page)
      |> Repo.insert()

    {:ok, %Page{id: login_page_id}} =
      %Page{}
      |> Page.changeset(login_page)
      |> Repo.insert()

    #

    _annotations = [
      next_button_outline = %{
        annotation_type_id: outline_id,
        color: "#7FBE7F",
        content_id: nil,
        description: "Outline",
        font_color: nil,
        font_size: nil,
        label: "1",
        name: "Outline",
        page_id: setup_page_id,
        size: nil,
        thickness: 12,
        x_offset: nil,
        x_orientation: nil,
        y_offset: nil,
        y_orientation: nil
      },
      badge_manager_button = %{
        annotation_type_id: outline_id,
        color: "#7FBE7F",
        content_id: nil,
        description: "Badge",
        font_color: nil,
        font_size: nil,
        label: "2",
        name: "Label",
        page_id: setup_page_id,
        size: 12,
        thickness: nil,
        x_offset: 0,
        x_orientation: "R",
        y_offset: 0,
        y_orientation: "T"
      }
    ]

    {:ok, %Annotation{id: next_button_outline_id}} =
      %Annotation{}
      |> Annotation.changeset(next_button_outline)
      |> Repo.insert()

    {:ok, %Annotation{id: badge_manager_button_id}} =
      %Annotation{}
      |> Annotation.changeset(badge_manager_button)
      |> Repo.insert()

    _elements = [
      setup_next = %{
        name: "Setup Next",
        page_id: setup_page_id,
        selector: "/html/body/div[@class='ember-view']/div[9]/div//form//button[contains(.,'Next')]",
        strategy_id: xpath_strategy_id
      },
      operator_button = %{
        name: "Operator Terminal Type Selection Button",
        page_id: setup_page_id,
        selector: "//body/div[@class='ember-view']/div[9]/div/div//form//div[@class='modal-container']/div/div[@class='content']/div/div[3]/div[3]",
        strategy_id: xpath_strategy_id
      },
      manager_button = %{
        name: "Manager Terminal Type Selection Button",
        page_id: setup_page_id,
        selector: "/html/body/div[@class='ember-view']/div[9]/div//form//div[@class='modal-container']/div/div[@class='content']/div/div[1]/div[3]",
        strategy_id: xpath_strategy_id
      },
      setup_next_2 = %{
        name: "Setup Next Page",
        page_id: setup_page_id,
        selector: "/html/body/div[@class='ember-view']/div[9]/div//form//button[contains(.,'Next Page')]",
        strategy_id: xpath_strategy_id
      },
      setup_save = %{
        name: "Setup Save Button",
        page_id: setup_page_id,
        selector: "/html/body/div[@class='ember-view']/div[9]/div//form//button[contains(.,'Save')]",
        strategy_id: xpath_strategy_id
      },
      login_button = %{
        name: "Login Button",
        page_id: login_page_id,
        selector: "/html/body/div[@class='ember-view']/div[9]//form//button",
        strategy_id: xpath_strategy_id
      },
      user_name_field = %{
        name: "User Name Field",
        page_id: login_page_id,
        selector: "/html/body/div[@class='ember-view']/div[9]/div//form//input[@placeholder='Username']",
        strategy_id: xpath_strategy_id
      },
      password_field = %{
        name: "Password",
        page_id: login_page_id,
        selector: "/html/body/div[@class='ember-view']/div[9]/div//form//input[@placeholder='Password']",
        strategy_id: xpath_strategy_id
      }
    ]

    {:ok, %Element{id: setup_next_id}} =
      %Element{}
      |> Element.changeset(setup_next)
      |> Repo.insert()

    {:ok, %Element{id: operator_button_id}} =
      %Element{}
      |> Element.changeset(operator_button)
      |> Repo.insert()

    {:ok, %Element{id: manager_button_id}} =
      %Element{}
      |> Element.changeset(manager_button)
      |> Repo.insert()

    {:ok, %Element{id: setup_next_2_id}} =
      %Element{}
      |> Element.changeset(setup_next_2)
      |> Repo.insert()

    {:ok, %Element{id: setup_save_id}} =
      %Element{}
      |> Element.changeset(setup_save)
      |> Repo.insert()

    {:ok, %Element{id: login_button_id}} =
      %Element{}
      |> Element.changeset(login_button)
      |> Repo.insert()

    {:ok, %Element{id: user_name_field_id}} =
      %Element{}
      |> Element.changeset(user_name_field)
      |> Repo.insert()

    {:ok, %Element{id: password_field_id}} =
      %Element{}
      |> Element.changeset(password_field)
      |> Repo.insert()

    _processes = [
      setup_process = %{
        name: "Setup Manager Session",
        order: 1,
        version_id: version_2020_1_id
      },
      login_process = %{
        name: "Login",
        order: 2,
        version_id: version_2020_1_id
      }
    ]

    {:ok, %Process{id: setup_process_id}} =
      %Process{}
      |> Process.changeset(setup_process)
      |> Repo.insert()

    {:ok, %Process{id: login_process_id}} =
      %Process{}
      |> Process.changeset(login_process)
      |> Repo.insert()

    # Processes

    steps = [
      %{
        annotation_id: nil,
        element_id: nil,
        height: nil,
        name: "Navigate to Setup",
        order: 10,
        page_id: nil,
        page_reference: nil,
        process_id: setup_process_id,
        step_type_id: navigate_id,
        text: nil,
        url: "https://staging.app.funnelcloud.io/#/setup",
        width: nil
      },
      %{
        annotation_id: nil,
        element_id: nil,
        height: 720,
        name: "Set Size",
        order: 20,
        page_id: nil,
        page_reference: nil,
        process_id: setup_process_id,
        step_type_id: set_size_explicit_id,
        text: nil,
        url: nil,
        width: 1280
      },
      %{
        annotation_id: nil,
        element_id: nil,
        height: nil,
        name: "Screenshot",
        order: 35,
        page_id: nil,
        page_reference: nil,
        process_id: setup_process_id,
        step_type_id: full_screen_screenshot_id,
        text: nil,
        url: nil,
        width: nil
      },
      %{
        annotation_id: nil,
        element_id: nil,
        height: nil,
        name: "Clear",
        order: 37,
        page_id: nil,
        page_reference: nil,
        process_id: setup_process_id,
        step_type_id: clear_annotations_id,
        text: nil,
        url: nil,
        width: nil
      },
      %{
        annotation_id: nil,
        element_id: setup_next_id,
        height: nil,
        name: "Click Next",
        order: 40,
        page_id: nil,
        page_reference: nil,
        process_id: setup_process_id,
        step_type_id: click_id,
        text: nil,
        url: nil,
        width: nil
      },
      %{
        annotation_id: nil,
        element_id: nil,
        height: nil,
        name: "Screenshot",
        order: 45,
        page_id: nil,
        page_reference: nil,
        process_id: setup_process_id,
        step_type_id: full_screen_screenshot_id,
        text: nil,
        url: nil,
        width: nil
      },
      %{
        annotation_id: nil,
        element_id: nil,
        height: nil,
        name: "Clear",
        order: 47,
        page_id: nil,
        page_reference: nil,
        process_id: setup_process_id,
        step_type_id: clear_annotations_id,
        text: nil,
        url: nil,
        width: nil
      },
      %{
        annotation_id: nil,
        element_id: manager_button_id,
        height: nil,
        name: "Click Manager Terminal",
        order: 50,
        page_id: nil,
        page_reference: nil,
        process_id: setup_process_id,
        step_type_id: click_id,
        text: nil,
        url: nil,
        width: nil
      },
      %{
        annotation_id: nil,
        element_id: setup_next_2_id,
        height: nil,
        name: "Click Next Page",
        order: 60,
        page_id: nil,
        page_reference: nil,
        process_id: setup_process_id,
        step_type_id: click_id,
        text: nil,
        url: nil,
        width: nil
      },
      %{
        annotation_id: nil,
        element_id: setup_save_id,
        height: nil,
        name: "Click Save Setup",
        order: 70,
        page_id: nil,
        page_reference: nil,
        process_id: setup_process_id,
        step_type_id: click_id,
        text: nil,
        url: nil,
        width: nil
      },
      %{
        annotation_id: nil,
        element_id: nil,
        height: nil,
        name: "Navigate to Login",
        order: 1,
        page_id: nil,
        page_reference: nil,
        process_id: login_process_id,
        step_type_id: navigate_id,
        text: nil,
        url: "https://staging.app.funnelcloud.io/#/login",
        width: nil
      },
      %{
        annotation_id: nil,
        element_id: login_button_id,
        height: nil,
        name: "Click Login",
        order: 2,
        page_id: nil,
        page_reference: nil,
        process_id: login_process_id,
        step_type_id: click_id,
        text: nil,
        url: nil,
        width: nil
      },
      %{
        annotation_id: nil,
        element_id: user_name_field_id,
        height: nil,
        name: "Enter Username",
        order: 3,
        page_id: nil,
        page_reference: nil,
        process_id: login_process_id,
        step_type_id: fill_field_id,
        text: "admin@funnelcloud.io",
        url: nil,
        width: nil
      },
      %{
        annotation_id: nil,
        element_id: password_field_id,
        height: nil,
        name: "Enter Password",
        order: 4,
        page_id: nil,
        page_reference: nil,
        process_id: login_process_id,
        step_type_id: fill_field_id,
        text: "FirstTimer",
        url: nil,
        width: nil
      },
      %{
        annotation_id: next_button_outline_id,
        element_id: setup_next_id,
        height: nil,
        name: "Outline Next",
        order: 30,
        page_id: setup_page_id,
        page_reference: nil,
        process_id: setup_process_id,
        step_type_id: apply_annotation_id,
        text: nil,
        url: nil,
        width: nil
      },
      %{
        annotation_id: badge_manager_button_id,
        element_id: manager_button_id,
        height: nil,
        name: "Badge Manager Terminal",
        order: 42,
        page_id: setup_page_id,
        page_reference: nil,
        process_id: setup_process_id,
        step_type_id: apply_annotation_id,
        text: nil,
        url: nil,
        width: nil
      }
    ]

    Enum.each(steps,
      fn(s) ->
        %Step{}
        |> Step.changeset(s)
        |> Repo.insert()
      end
    )

    _content = [
      login_button = %{
        name: "login button",
        team_id: funnel_cloud_team_id
      },
      manager_button = %{
        name: "Manager button",
        team_id: funnel_cloud_team_id
      },
      operator_button = %{
        name: "Operator button",
        team_id: funnel_cloud_team_id
      },
      john_rocks = %{
        name: "John Rocks",
        team_id: loreline_team_id
      }
    ]

    {:ok, %Content{id: login_button_id}} =
      %Content{}
      |> Content.changeset(login_button)
      |> Repo.insert()

    {:ok, %Content{id: manager_button_id}} =
      %Content{}
      |> Content.changeset(manager_button)
      |> Repo.insert()

    {:ok, %Content{id: operator_button_id}} =
      %Content{}
      |> Content.changeset(operator_button)
      |> Repo.insert()

    {:ok, %Content{id: john_rocks_id}} =
      %Content{}
      |> Content.changeset(john_rocks)
      |> Repo.insert()

    english_language_code = %{
      code: "en-US"
    }

    great_britain_language_code = %{
      code: "en-GB"
    }

    {:ok, %LanguageCode{id: english_language_code_id}} =
      %LanguageCode{}
      |> LanguageCode.changeset(english_language_code)
      |> Repo.insert()

    {:ok, %LanguageCode{id: great_britain_language_code_id}} =
      %LanguageCode{}
      |> LanguageCode.changeset(great_britain_language_code)
      |> Repo.insert()

    content_versions = [
      _login_button_2020_1_en_us = %{
        language_code_id: english_language_code_id,
        name: "Login Button",
        body: "The login button will log you in.",
        content_id: login_button_id,
        version_id: version_2020_1_id,
      },
      _login_button_2020_1_en_gb = %{
        language_code_id: great_britain_language_code_id,
        name: "Login Button",
        body: "This login button shall log you in.",
        content_id: login_button_id,
        version_id: version_2020_1_id,
      },
      _manager_button_2020_1_en_us = %{
        language_code_id: english_language_code_id,
        name: "Manager Button",
        body: "This manager button picks the manager terminal type.",
        content_id: manager_button_id,
        version_id: version_2020_1_id,
      },
      _manager_button_2020_1_en_gb = %{
        language_code_id: great_britain_language_code_id,
        name: "Manager Button",
        body: "This manager button picks thine manager terminal type.",
        content_id: manager_button_id,
        version_id: version_2020_1_id,
      },
      _operator_button_2020_1_en_us = %{
        language_code_id: english_language_code_id,
        name: "Operator Button",
        body: "The operator button picks the manager terminal type.",
        content_id: operator_button_id,
        version_id: version_2020_1_id,
      },
      _operator_button_2020_1_en_gb = %{
        language_code_id: great_britain_language_code_id,
        name: "Operator Button",
        body: "The operator button picks thine manager terminal type.",
        content_id: operator_button_id,
        version_id: version_2020_1_id,
      },
      _loreline_content = %{
        language_code_id: english_language_code_id,
        name: "Test",
        body: "Shouldn't show up on the main screen.",
        content_id: john_rocks_id,
        version_id: version_2020_1_id,
      }
    ]

    Enum.each(content_versions,
      fn(cv) ->
        IO.puts("Inserting cv")
        %ContentVersion{}
        |> ContentVersion.changeset(cv)
        |> Repo.insert()
      end
    )

    document_attrs = %{
      name: "Cycle Profile Form Reference",
      title: "Cycle Profile Form Reference",
      project_id: funnelcloud_manager_project_id
    }

    { :ok, %Document{id: document_id} } =
      Documents.create_document(document_attrs)

    document_version = %{
      name: "test",
      title: "test",
      version_id: version_2020_1_id,
      document_id: document_id
    }

    {:ok, %DocumentVersion{id: document_version_id}} =
    %DocumentVersion{}
    |> DocumentVersion.changeset(document_version)
    |> Repo.insert()

  ""
  end

end

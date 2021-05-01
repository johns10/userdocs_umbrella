defmodule UserDocs.TestDataset do

  alias UserDocs.Users
  alias UserDocs.Users.User
  alias UserDocs.Users.Team
  alias UserDocs.Users.TeamUser

  alias UserDocs.Projects
  alias UserDocs.Projects.Project
  alias UserDocs.Projects.Version

  alias UserDocs.Documents
  alias UserDocs.Documents.DocubitType
  alias UserDocs.Documents.Docubit
  alias UserDocs.Documents.Document
  alias UserDocs.Documents.DocumentVersion
  alias UserDocs.Documents.Content
  alias UserDocs.Documents.ContentVersion
  alias UserDocs.Documents.LanguageCode

  alias UserDocs.Web.Page
  alias UserDocs.Web.AnnotationType
  alias UserDocs.Web.Annotation
  alias UserDocs.Web.Element
  alias UserDocs.Web.Strategy

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
    Repo.delete_all(LanguageCode)
    Repo.delete_all(Docubit)
    Repo.delete_all(DocubitType)
    Enum.each(Users.list_teams, fn(t) -> Users.delete_team(t) end)
    Enum.each(Users.list_users, fn(u) -> Users.delete_user(u) end)
  end

  def create_base_data() do
    strategies = [
      _xpath_strategy = %{
        name: "xpath"
      },
      _css_strategy = %{
        name: "css"
      }
    ]

    Enum.each(strategies, fn(strategy) -> UserDocs.Web.create_strategy(strategy) end)

    annotation_types = [
      %{
        args: ["color", "thickness"],
        name: "Outline"
      },
      %{
        args: ["color", "thickness"],
        name: "Blur"
      },
      %{
        args: ["x_orientation", "y_orientation", "size", "label", "color", "x_offset", "y_offset", "font_size"],
        name: "Badge"
      },
      %{
        args: ["x_orientation", "y_orientation", "size", "label", "color",
         "x_offset", "y_offset", "font_size"],
        name: "Badge Blur"
      },
      %{
        args: ["x_orientation", "y_orientation", "size", "label", "color",
         "thickness", "x_offset", "y_offset", "font_size"],
        name: "Badge Outline"
      }
    ]

    Enum.each(annotation_types, fn(annotation_type) -> UserDocs.Web.create_annotation_type(annotation_type) end)

    step_types = [
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
      },
      %{ args: ["element_id"], name: "Scroll to Element" },
      %{ args: ["element_id"], name: "Send Enter Key" }
    ]

    Enum.each(step_types, fn(step_type) -> UserDocs.Automation.create_step_type(step_type) end)
  end

  def create() do

  _strategies = [
    xpath_strategy = %{
      name: "xpath"
    },
    css_strategy = %{
      name: "css"
    }
  ]

  {:ok, %UserDocs.Web.Strategy{ id: xpath_strategy_id}} =
    %Strategy{}
    |> Strategy.changeset(xpath_strategy)
    |> Repo.insert()

  {:ok, %Strategy{ id: css_strategy_id}} =
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

  {:ok, %AnnotationType{id: _badge_outline_id}} =
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

  {:ok, %StepType{id: _fill_field_id}} =
    %StepType{}
    |> StepType.changeset(fill_field)
    |> Repo.insert()

  {:ok, %StepType{id: _apply_annotation_id}} =
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

  {:ok, %StepType{id: _element_screenshot_id}} =
    %StepType{}
    |> StepType.changeset(element_screenshot)
    |> Repo.insert()

    # User Data

    default_password = "userdocs"

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

    test_user_1 =
      %{
        email: "user@organization.com",
        password: "testtesttest",
        password_confirmation: "testtesttest"
      }

    test_user_2 =
      %{
        email: "user2@organization.com",
        password: "testtesttest",
        password_confirmation: "testtesttest"
      }

    {:ok, user_1 = %User{id: user1_id}} =
      %User{}
      |> User.changeset(user_1)
      |> Repo.insert()

    {:ok, user_2 = %User{id: user2_id}} =
    %User{}
    |> User.changeset(user_2)
    |> Repo.insert()

    {:ok, _ } =
      %User{}
      |> User.changeset(test_user_1)
      |> Repo.insert()

    {:ok, _ } =
      %User{}
      |> User.changeset(test_user_2)
      |> Repo.insert()

    # Team Data

    userdocs_team =
      %{
        name: "UserDocs"
      }

    loreline_team =
      %{
        name: "LoreLine"
      }

    {:ok, userdocs_team = %Team{id: userdocs_team_id}} =
      %Team{}
      |> Team.changeset(userdocs_team)
      |> Repo.insert()

    {:ok, loreline_team = %Team{id: loreline_team_id}} =
      %Team{}
      |> Team.changeset(loreline_team)
      |> Repo.insert()

    Users.update_user(
      user_1,
      %{ default_team_id: userdocs_team_id, current_password: default_password }
    )

    Users.update_user(
      user_2,
      %{ default_team_id: userdocs_team_id, current_password: default_password }
    )

    # Team Users

    team_users = [
      %{
        team_id: userdocs_team_id,
        user_id: user1_id
      },
      %{
        team_id: userdocs_team_id,
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

    the_internet_project =
      %{
        base_url: "https://the-internet.herokuapp.com",
        name: "The Internet",
        team_id: userdocs_team_id
      }
    userdocs_project =
      %{
        base_url: "https://app.user-docs.com",
        name: "Userdocs",
        team_id: userdocs_team_id
      }

    john_davenport_rocks_project =
      %{
        base_url: "https://www.davenport.rocks",
        name: "John Davenport Rocks",
        team_id: loreline_team_id
      }

    {:ok, the_internet_project = %Project{id: _the_internet_project_id}} =
      %Project{}
      |> Project.changeset(the_internet_project)
      |> Repo.insert()

    {:ok, userdocs_project = %Project{id: userdocs_project_id}} =
      %Project{}
      |> Project.changeset(userdocs_project)
      |> Repo.insert()

    {:ok, john_davenport_rocks_project = %Project{id: john_davenport_rocks_project_id}} =
      %Project{}
      |> Project.changeset(john_davenport_rocks_project)
      |> Repo.insert()


    Users.update_team(userdocs_team, %{ default_project_id: userdocs_project_id})

    # Versions

    version_0_0_1 = %{
      name: "0.0.1",
      order: 1,
      project_id: userdocs_project_id,
      strategy_id: css_strategy_id
    }

    version_0_0_2 = %{
      name: "0_0_2",
      order: 2,
      project_id: userdocs_project_id,
      strategy_id: css_strategy_id
    }

    version_1 = %{
      name: "Version 1",
      project_id: john_davenport_rocks_project_id,
      strategy_id: css_strategy_id
    }

    {:ok, _version_0_0_1 = %Version{id: version_0_0_1_id}} =
      %Version{}
      |> Version.changeset(version_0_0_1)
      |> Repo.insert()

    {:ok, _version_0_0_2 = %Version{id: version_0_0_2_id}} =
      %Version{}
      |> Version.changeset(version_0_0_2)
      |> Repo.insert()

    {:ok, _version_1 = %Version{id: version_1_id}} =
      %Version{}
      |> Version.changeset(version_1)
      |> Repo.insert()

    Projects.update_project(the_internet_project, %{default_version_id: version_0_0_1_id})
    Projects.update_project(userdocs_project, %{default_version_id: version_0_0_2_id})
    Projects.update_project(john_davenport_rocks_project, %{default_version_id: version_1_id})

    { :ok, _user_1 } = Users.update_user(user_1, %{
      current_password: default_password,
      selected_team_id: userdocs_team_id,
      selected_project_id: userdocs_project_id,
      selected_version_id: version_0_0_1_id
    })

    # Pages

    add_remove_page = %{
      name: "Setup",
      order: 1,
      url: "https://the-internet.herokuapp.com/add_remove_elements/",
      version_id: version_0_0_1_id
    }

    processes_page = %{
      name: "Login",
      order: 2,
      url: "https://app.user-docs.com/processes",
      version_id: version_0_0_2_id
    }

    {:ok, %Page{id: add_remove_page_id}} =
      %Page{}
      |> Page.changeset(add_remove_page)
      |> Repo.insert()

    {:ok, %Page{id: _processes_page_id}} =
      %Page{}
      |> Page.changeset(processes_page)
      |> Repo.insert()

    #

    _annotations = [
      add_outline = %{
        annotation_type_id: outline_id,
        color: "#7FBE7F",
        content_id: nil,
        description: "Outline",
        font_color: nil,
        font_size: nil,
        label: "1",
        name: "Outline",
        page_id: add_remove_page_id,
        size: nil,
        thickness: 12,
        x_offset: nil,
        x_orientation: nil,
        y_offset: nil,
        y_orientation: nil
      },
      badge_remove_button = %{
        annotation_type_id: outline_id,
        color: "#7FBE7F",
        content_id: nil,
        description: "Badge",
        font_color: nil,
        font_size: nil,
        label: "2",
        name: "Label",
        page_id: add_remove_page_id,
        size: 12,
        thickness: nil,
        x_offset: 0,
        x_orientation: "R",
        y_offset: 0,
        y_orientation: "T"
      }
    ]

    {:ok, %Annotation{id: add_outline_id}} =
      %Annotation{}
      |> Annotation.changeset(add_outline)
      |> Repo.insert()

    {:ok, %Annotation{id: badge_remove_button_id}} =
      %Annotation{}
      |> Annotation.changeset(badge_remove_button)
      |> Repo.insert()

    _elements = [
      add_element = %{
        name: "Add Element Button",
        page_id: add_remove_page_id,
        selector: "//buton[.='Add Element']",
        strategy_id: xpath_strategy_id
      },
      _delete_element = %{
        name: "Operator Terminal Type Selection Button",
        page_id: add_remove_page_id,
        selector: "//buton[.='Delete]",
        strategy_id: xpath_strategy_id
      }
    ]

    {:ok, %Element{id: add_element_id}} =
      %Element{}
      |> Element.changeset(add_element)
      |> Repo.insert()

    {:ok, %Element{id: _add_element_id}} =
      %Element{}
      |> Element.changeset(add_element)
      |> Repo.insert()

    _processes = [
      add_remove_process = %{
        name: "Add and Remove Elements",
        order: 1,
        version_id: version_0_0_1_id
      },
      add_process = %{
        name: "Add Process",
        order: 2,
        version_id: version_0_0_2_id
      }
    ]

    {:ok, %Process{id: add_remove_process_id}} =
      %Process{}
      |> Process.changeset(add_remove_process)
      |> Repo.insert()

    {:ok, %Process{id: _add_process_id}} =
      %Process{}
      |> Process.changeset(add_process)
      |> Repo.insert()

    # Processes

    steps = [
      %{
        annotation_id: nil,
        element_id: nil,
        height: nil,
        name: "Navigate to Add Remove Elements",
        order: 10,
        page_id: nil,
        page_reference: nil,
        process_id: add_remove_process_id,
        step_type_id: navigate_id,
        text: nil,
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
        process_id: add_remove_process_id,
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
        process_id: add_remove_process_id,
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
        process_id: add_remove_process_id,
        step_type_id: clear_annotations_id,
        text: nil,
        url: nil,
        width: nil
      },
      %{
        annotation_id: nil,
        element_id: add_element_id,
        height: nil,
        name: "Click Add Element",
        order: 40,
        page_id: nil,
        page_reference: nil,
        process_id: add_remove_process_id,
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
        process_id: add_remove_process_id,
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
        process_id: add_remove_process_id,
        step_type_id: clear_annotations_id,
        text: nil,
        url: nil,
        width: nil
      },
      %{
        annotation_id: nil,
        element_id: add_element_id,
        height: nil,
        name: "Click Delete",
        order: 50,
        page_id: nil,
        page_reference: nil,
        process_id: add_remove_process_id,
        step_type_id: click_id,
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
      add_element_button = %{
        name: "Add Element Button",
        team_id: userdocs_team_id
      },
      delete_button = %{
        name: "Delete Element button",
        team_id: userdocs_team_id
      }
    ]

    {:ok, %Content{id: add_element_button_id}} =
      %Content{}
      |> Content.changeset(add_element_button)
      |> Repo.insert()

    {:ok, %Content{id: delete_button_id}} =
      %Content{}
      |> Content.changeset(delete_button)
      |> Repo.insert()


    english_language_code = %{
      name: "en-US"
    }

    great_britain_language_code = %{
      name: "en-GB"
    }

    {:ok, %LanguageCode{id: english_language_code_id}} =
      %LanguageCode{}
      |> LanguageCode.changeset(english_language_code)
      |> Repo.insert()

    {:ok, %LanguageCode{id: great_britain_language_code_id}} =
      %LanguageCode{}
      |> LanguageCode.changeset(great_britain_language_code)
      |> Repo.insert()

    {:ok, _userdocs_team = %Team{}} =
      userdocs_team
      |> Users.update_team(%{default_language_code_id: english_language_code_id})

    {:ok, _loreline_team = %Team{}} =
      loreline_team
      |> Users.update_team(%{default_language_code_id: english_language_code_id})

    content_versions = [
      _login_button_2020_1_en_us = %{
        language_code_id: add_element_button_id,
        name: "Add Element",
        body: "The add element button adds an element",
        content_id: add_element_button_id,
        version_id: version_0_0_1_id,
      },
      _login_button_2020_1_en_gb = %{
        language_code_id: great_britain_language_code_id,
        name: "Add Element",
        body: "The add element button shall add an element",
        content_id: add_element_button_id,
        version_id: version_0_0_1_id,
      },
      _manager_button_2020_1_en_us = %{
        language_code_id: english_language_code_id,
        name: "Delete Button",
        body: "This button deletes an element",
        content_id: delete_button_id,
        version_id: version_0_0_1_id,
      },
      _manager_button_2020_1_en_gb = %{
        language_code_id: great_britain_language_code_id,
        name: "Delete Button",
        body: "This button shall delete an element",
        content_id: delete_button_id,
        version_id: version_0_0_1_id,
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
      project_id: userdocs_project_id
    }

    { :ok, %Document{id: document_id} } =
      Documents.create_document(document_attrs)

    _docubit_types =
      Enum.map(
        UserDocs.Documents.DocubitType.attrs(),
        fn(attrs) ->
          { :ok, docubit_type } = Documents.create_docubit_type(attrs)
          docubit_type
        end
      )

    document_version = %{
      name: "test",
      title: "test",
      version_id: version_0_0_1_id,
      document_id: document_id
    }

    {:ok, %DocumentVersion{id: _document_version_id}} =
      Documents.create_document_version(document_version)

  end

end

git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch apps/userdocs/lib/userdocs/userdocs_test_dataset.ex" \
  --prune-empty --tag-name-filter cat -- --all

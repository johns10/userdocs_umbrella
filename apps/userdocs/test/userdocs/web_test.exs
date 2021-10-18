defmodule UserDocs.WebTest do
  use UserDocs.DataCase

  alias UserDocs.Web
  alias UserDocs.Annotations
  alias UserDocs.AutomationFixtures
  alias UserDocs.Elements
  alias UserDocs.UsersFixtures
  alias UserDocs.ProjectsFixtures
  alias UserDocs.WebFixtures

  defp fixture(:user), do: UsersFixtures.user()
  defp fixture(:team), do: UsersFixtures.team()
  defp fixture(:strategy), do: WebFixtures.strategy()
  defp fixture(:team_user, user_id, team_id), do: UsersFixtures.team_user(user_id, team_id)
  defp fixture(:project, team_id, strategy_id), do: ProjectsFixtures.project(team_id, strategy_id)
  defp fixture(:process, project_id), do: AutomationFixtures.process(project_id)
  defp fixture(:page, project_id), do: WebFixtures.page(project_id)

  defp create_user(_), do: %{user: fixture(:user)}
  defp create_team(_), do: %{team: fixture(:team)}
  defp create_team_user(%{user: user, team: team}), do: %{team_user: fixture(:team_user, user.id, team.id)}
  defp create_project(%{team: team, strategy: strategy}), do: %{project: fixture(:project, team.id, strategy.id)}
  defp create_process(%{project: project}), do: %{process: fixture(:process, project.id)}
  defp create_page(%{project: project}), do: %{page: fixture(:page, project.id)}
  defp create_strategy(_), do: %{strategy: fixture(:strategy)}

  describe "pages" do
    alias UserDocs.Web.Page

    @valid_attrs %{url: "some url"}
    @update_attrs %{url: "some updated url"}
    @invalid_attrs %{url: nil}

    def page_fixture(attrs \\ %{}) do
      {:ok, page} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Web.create_page()

      page
    end

    test "list_pages/0 returns all pages" do
      page = page_fixture()
      assert Web.list_pages() == [page]
    end

    test "get_page!/1 returns the page with given id" do
      page = page_fixture()
      assert Web.get_page!(page.id) == page
    end

    test "create_page/1 with valid data creates a page" do
      assert {:ok, %Page{} = page} = Web.create_page(@valid_attrs)
      assert page.url == "some url"
    end

    test "create_page/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Web.create_page(@invalid_attrs)
    end

    test "update_page/2 with valid data updates the page" do
      page = page_fixture()
      assert {:ok, %Page{} = page} = Web.update_page(page, @update_attrs)
      assert page.url == "some updated url"
    end

    test "update_page/2 with invalid data returns error changeset" do
      page = page_fixture()
      assert {:error, %Ecto.Changeset{}} = Web.update_page(page, @invalid_attrs)
      assert page == Web.get_page!(page.id)
    end

    test "delete_page/1 deletes the page" do
      page = page_fixture()
      assert {:ok, %Page{}} = Web.delete_page(page)
      assert_raise Ecto.NoResultsError, fn -> Web.get_page!(page.id) end
    end

    test "change_page/1 returns a page changeset" do
      page = page_fixture()
      assert %Ecto.Changeset{} = Web.change_page(page)
    end
  end

  describe "annotation_types" do
    alias UserDocs.Annotations.AnnotationType

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def annotation_type_fixture(attrs \\ %{}) do
      {:ok, annotation_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Annotations.create_annotation_type()

      annotation_type
    end

    test "list_annotation_types/0 returns all annotation_types" do
      annotation_type = annotation_type_fixture()
      assert Annotations.list_annotation_types() == [annotation_type]
    end

    test "get_annotation_type!/1 returns the annotation_type with given id" do
      annotation_type = annotation_type_fixture()
      assert Annotations.get_annotation_type!(annotation_type.id) == annotation_type
    end

    test "create_annotation_type/1 with valid data creates a annotation_type" do
      assert {:ok, %AnnotationType{} = annotation_type} = Annotations.create_annotation_type(@valid_attrs)
      assert annotation_type.name == "some name"
    end

    test "create_annotation_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Annotations.create_annotation_type(@invalid_attrs)
    end

    test "update_annotation_type/2 with valid data updates the annotation_type" do
      annotation_type = annotation_type_fixture()
      assert {:ok, %AnnotationType{} = annotation_type} = Annotations.update_annotation_type(annotation_type, @update_attrs)
      assert annotation_type.name == "some updated name"
    end

    test "update_annotation_type/2 with invalid data returns error changeset" do
      annotation_type = annotation_type_fixture()
      assert {:error, %Ecto.Changeset{}} = Annotations.update_annotation_type(annotation_type, @invalid_attrs)
      assert annotation_type == Annotations.get_annotation_type!(annotation_type.id)
    end

    test "delete_annotation_type/1 deletes the annotation_type" do
      annotation_type = annotation_type_fixture()
      assert {:ok, %AnnotationType{}} = Annotations.delete_annotation_type(annotation_type)
      assert_raise Ecto.NoResultsError, fn -> Annotations.get_annotation_type!(annotation_type.id) end
    end

    test "change_annotation_type/1 returns a annotation_type changeset" do
      annotation_type = annotation_type_fixture()
      assert %Ecto.Changeset{} = Annotations.change_annotation_type(annotation_type)
    end
  end

  describe "elements" do
    alias UserDocs.Elements.Element

    setup [
      :create_user,
      :create_strategy,
      :create_team,
      :create_team_user,
      :create_project,
      :create_process,
      :create_page
    ]

    test "list_elements/0 returns all elements", %{page: page, strategy: strategy} do
      element = WebFixtures.element(page.id, strategy.id)
      assert Elements.list_elements() == [element]
    end

    test "get_element!/1 returns the element with given id", %{page: page, strategy: strategy} do
      element = WebFixtures.element(page.id, strategy.id)
      assert Elements.get_element!(element.id) == element
    end

    test "create_element/1 with valid data creates a element", %{page: page, strategy: strategy} do
      attrs = WebFixtures.element_attrs(:valid, page.id, strategy.id)
      assert {:ok, %Element{} = element} = Elements.create_element(attrs)
      assert element.name == attrs.name
      assert element.selector == attrs.selector
    end

    test "create_element/1 with invalid data returns error changeset", %{page: page, strategy: strategy} do
      attrs = WebFixtures.element_attrs(:invalid, page.id, strategy.id)
      assert {:error, %Ecto.Changeset{}} = Elements.create_element(attrs)
    end

    test "update_element/2 with valid data updates the element", %{page: page, strategy: strategy} do
      element = WebFixtures.element(page.id, strategy.id)
      attrs = WebFixtures.element_attrs(:valid, page.id, strategy.id)
      assert {:ok, %Element{} = element} = Elements.update_element(element, attrs)
      assert element.name == attrs.name
      assert element.selector == attrs.selector
    end

    test "update_element/2 with invalid data returns error changeset", %{page: page, strategy: strategy} do
      element = WebFixtures.element(page.id, strategy.id)
      attrs = WebFixtures.element_attrs(:invalid, page.id, strategy.id)
      assert {:error, %Ecto.Changeset{}} = Elements.update_element(element, attrs)
      assert element == Elements.get_element!(element.id)
    end

    test "delete_element/1 deletes the element", %{page: page, strategy: strategy} do
      element = WebFixtures.element(page.id, strategy.id)
      assert {:ok, %Element{}} = Elements.delete_element(element)
      assert_raise Ecto.NoResultsError, fn -> Elements.get_element!(element.id) end
    end

    test "change_element/1 returns a element changeset", %{page: page, strategy: strategy} do
      element = WebFixtures.element(page.id, strategy.id)
      assert %Ecto.Changeset{} = Elements.change_element(element)
    end
  end

  describe "annotations" do
    alias UserDocs.Annotations.Annotation
    alias UserDocs.Web.Page

    @valid_attrs %{
      label: "some label",
      name: "some name"
    }

    @update_attrs %{
      label: "some updated label",
      name: "some updated name"
    }

    @invalid_attrs %{description: nil, label: nil, name: nil, page_id: nil}
    @page_attrs %{url: "some url"}

    def annotation_fixture(attrs \\ %{}, page_attrs \\ @page_attrs) do
      {:ok, page} =
        page_attrs
        |> Web.create_page()

      {:ok, annotation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:page_id, Integer.to_string(page.id))
        |> Annotations.create_annotation()

      annotation
    end

    test "list_annotations/0 returns all annotations" do
      annotation = annotation_fixture()
      assert Annotations.list_annotations() == [annotation]
    end

    test "get_annotation!/1 returns the annotation with given id" do
      annotation = annotation_fixture()
      assert Annotations.get_annotation!(annotation.id) == annotation
    end

    test "create_annotation/1 with valid data creates a annotation" do
      {:ok, %Page{} = page} = Web.create_page(@page_attrs)
      attrs = Map.put(@valid_attrs, :page_id, page.id)
      assert {:ok, %Annotation{} = annotation} = Annotations.create_annotation(attrs)
      assert annotation.label == "some label"
      assert annotation.name == "some name"
    end

    test "create_annotation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Annotations.create_annotation(@invalid_attrs)
    end

    test "update_annotation/2 with valid data updates the annotation" do
      annotation = annotation_fixture()
      assert {:ok, %Annotation{} = annotation} =
        Annotations.update_annotation(annotation, @update_attrs)

      assert annotation.label == @update_attrs.label
      assert annotation.name == @update_attrs.name
    end

    test "update_annotation/2 with invalid data returns error changeset" do
      annotation = annotation_fixture()
      assert {:error, %Ecto.Changeset{}} = Annotations.update_annotation(annotation, @invalid_attrs)
      assert annotation == Annotations.get_annotation!(annotation.id)
    end

    test "delete_annotation/1 deletes the annotation" do
      annotation = annotation_fixture()
      assert {:ok, %Annotation{}} = Annotations.delete_annotation(annotation)
      assert_raise Ecto.NoResultsError, fn -> Annotations.get_annotation!(annotation.id) end
    end

    test "change_annotation/1 returns a annotation changeset" do
      annotation = annotation_fixture()
      assert %Ecto.Changeset{} = Annotations.change_annotation(annotation)
    end
  end
end

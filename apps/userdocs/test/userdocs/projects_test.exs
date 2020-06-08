defmodule UserDocs.ProjectsTest do
  use UserDocs.DataCase

  alias UserDocs.Projects

  describe "projects" do
    alias UserDocs.Projects.Project

    @valid_attrs %{base_url: "some base_url", name: "some name"}
    @update_attrs %{base_url: "some updated base_url", name: "some updated name"}
    @invalid_attrs %{base_url: nil, name: nil}

    def project_fixture(attrs \\ %{}) do
      {:ok, project} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Projects.create_project()

      project
    end

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert Projects.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Projects.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      assert {:ok, %Project{} = project} = Projects.create_project(@valid_attrs)
      assert project.base_url == "some base_url"
      assert project.name == "some name"
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()
      assert {:ok, %Project{} = project} = Projects.update_project(project, @update_attrs)
      assert project.base_url == "some updated base_url"
      assert project.name == "some updated name"
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert project == Projects.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end

  describe "versions" do
    alias UserDocs.Projects.Version

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def version_fixture(attrs \\ %{}) do
      {:ok, version} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Projects.create_version()

      version
    end

    test "list_versions/0 returns all versions" do
      version = version_fixture()
      assert Projects.list_versions() == [version]
    end

    test "get_version!/1 returns the version with given id" do
      version = version_fixture()
      assert Projects.get_version!(version.id) == version
    end

    test "create_version/1 with valid data creates a version" do
      assert {:ok, %Version{} = version} = Projects.create_version(@valid_attrs)
      assert version.name == "some name"
    end

    test "create_version/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_version(@invalid_attrs)
    end

    test "update_version/2 with valid data updates the version" do
      version = version_fixture()
      assert {:ok, %Version{} = version} = Projects.update_version(version, @update_attrs)
      assert version.name == "some updated name"
    end

    test "update_version/2 with invalid data returns error changeset" do
      version = version_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_version(version, @invalid_attrs)
      assert version == Projects.get_version!(version.id)
    end

    test "delete_version/1 deletes the version" do
      version = version_fixture()
      assert {:ok, %Version{}} = Projects.delete_version(version)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_version!(version.id) end
    end

    test "change_version/1 returns a version changeset" do
      version = version_fixture()
      assert %Ecto.Changeset{} = Projects.change_version(version)
    end
  end
end

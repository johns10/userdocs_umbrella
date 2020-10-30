defmodule UserDocs.WebTest do
  use UserDocs.DataCase

  alias UserDocs.Web

  describe "pages" do
    alias UserDocs.Web.Page

    @valid_attrs %{url: "some url", version_id: ""}
    @update_attrs %{url: "some updated url", version_id: ""}
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
    alias UserDocs.Web.AnnotationType

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def annotation_type_fixture(attrs \\ %{}) do
      {:ok, annotation_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Web.create_annotation_type()

      annotation_type
    end

    test "list_annotation_types/0 returns all annotation_types" do
      annotation_type = annotation_type_fixture()
      assert Web.list_annotation_types() == [annotation_type]
    end

    test "get_annotation_type!/1 returns the annotation_type with given id" do
      annotation_type = annotation_type_fixture()
      assert Web.get_annotation_type!(annotation_type.id) == annotation_type
    end

    test "create_annotation_type/1 with valid data creates a annotation_type" do
      assert {:ok, %AnnotationType{} = annotation_type} = Web.create_annotation_type(@valid_attrs)
      assert annotation_type.name == "some name"
    end

    test "create_annotation_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Web.create_annotation_type(@invalid_attrs)
    end

    test "update_annotation_type/2 with valid data updates the annotation_type" do
      annotation_type = annotation_type_fixture()
      assert {:ok, %AnnotationType{} = annotation_type} = Web.update_annotation_type(annotation_type, @update_attrs)
      assert annotation_type.name == "some updated name"
    end

    test "update_annotation_type/2 with invalid data returns error changeset" do
      annotation_type = annotation_type_fixture()
      assert {:error, %Ecto.Changeset{}} = Web.update_annotation_type(annotation_type, @invalid_attrs)
      assert annotation_type == Web.get_annotation_type!(annotation_type.id)
    end

    test "delete_annotation_type/1 deletes the annotation_type" do
      annotation_type = annotation_type_fixture()
      assert {:ok, %AnnotationType{}} = Web.delete_annotation_type(annotation_type)
      assert_raise Ecto.NoResultsError, fn -> Web.get_annotation_type!(annotation_type.id) end
    end

    test "change_annotation_type/1 returns a annotation_type changeset" do
      annotation_type = annotation_type_fixture()
      assert %Ecto.Changeset{} = Web.change_annotation_type(annotation_type)
    end
  end

  describe "elements" do
    alias UserDocs.Web.Element
    alias UserDocs.Web.Strategy

    @valid_attrs %{
      name: "some name",
      selector: "some selector"
    }

    @update_attrs %{
      name: "some updated name",
      selector: "some updated selector",
    }

    @invalid_attrs %{name: nil, selector: nil, strategy: nil}
    @strategy %{ name: "strategy" }

    def element_fixture(attrs \\ %{}, strategy_attrs \\ @strategy) do
      {:ok, strategy} =
        strategy_attrs
        |> Web.create_strategy()

      {:ok, element} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:strategy_id, strategy.id)
        |> Web.create_element()

      element
    end

    test "list_elements/0 returns all elements" do
      element = element_fixture()
      assert Web.list_elements() == [element]
    end

    test "get_element!/1 returns the element with given id" do
      element = element_fixture()
      assert Web.get_element!(element.id) == element
    end

    test "create_element/1 with valid data creates a element" do
      assert {:ok, %Strategy{} = strategy} = Web.create_strategy(@strategy)
      attrs = Map.put(@valid_attrs, :strategy_id, strategy.id)
      assert {:ok, %Element{} = element} = Web.create_element(attrs)
      assert element.name == "some name"
      assert element.selector == "some selector"
    end

    test "create_element/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Web.create_element(@invalid_attrs)
    end

    test "update_element/2 with valid data updates the element" do
      element = element_fixture()
      assert {:ok, %Element{} = element} = Web.update_element(element, @update_attrs)
      assert element.name == "some updated name"
      assert element.selector == "some updated selector"
    end

    test "update_element/2 with invalid data returns error changeset" do
      element = element_fixture()
      assert {:error, %Ecto.Changeset{}} = Web.update_element(element, @invalid_attrs)
      assert element == Web.get_element!(element.id)
    end

    test "delete_element/1 deletes the element" do
      element = element_fixture()
      assert {:ok, %Element{}} = Web.delete_element(element)
      assert_raise Ecto.NoResultsError, fn -> Web.get_element!(element.id) end
    end

    test "change_element/1 returns a element changeset" do
      element = element_fixture()
      assert %Ecto.Changeset{} = Web.change_element(element)
    end
  end

  describe "annotations" do
    alias UserDocs.Web.Annotation
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
    @page_attrs %{url: "some url", version_id: ""}

    def annotation_fixture(attrs \\ %{}, page_attrs \\ @page_attrs) do
      {:ok, page} =
        page_attrs
        |> Web.create_page()

      {:ok, annotation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:page_id, Integer.to_string(page.id))
        |> Web.create_annotation()

      annotation
    end

    test "list_annotations/0 returns all annotations" do
      annotation = annotation_fixture()
      assert Web.list_annotations() == [annotation]
    end

    test "get_annotation!/1 returns the annotation with given id" do
      annotation = annotation_fixture()
      assert Web.get_annotation!(annotation.id) == annotation
    end

    test "create_annotation/1 with valid data creates a annotation" do
      {:ok, %Page{} = page } = Web.create_page(@page_attrs)
      attrs = Map.put(@valid_attrs, :page_id, page.id)
      assert {:ok, %Annotation{} = annotation} = Web.create_annotation(attrs)
      assert annotation.label == "some label"
      assert annotation.name == "some name"
    end

    test "create_annotation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Web.create_annotation(@invalid_attrs)
    end

    test "update_annotation/2 with valid data updates the annotation" do
      annotation = annotation_fixture()
      assert {:ok, %Annotation{} = annotation} =
        Web.update_annotation(annotation, @update_attrs)

      assert annotation.label == @update_attrs.label
      assert annotation.name == @update_attrs.name
    end

    test "update_annotation/2 with invalid data returns error changeset" do
      annotation = annotation_fixture()
      assert {:error, %Ecto.Changeset{}} = Web.update_annotation(annotation, @invalid_attrs)
      assert annotation == Web.get_annotation!(annotation.id)
    end

    test "delete_annotation/1 deletes the annotation" do
      annotation = annotation_fixture()
      assert {:ok, %Annotation{}} = Web.delete_annotation(annotation)
      assert_raise Ecto.NoResultsError, fn -> Web.get_annotation!(annotation.id) end
    end

    test "change_annotation/1 returns a annotation changeset" do
      annotation = annotation_fixture()
      assert %Ecto.Changeset{} = Web.change_annotation(annotation)
    end
  end
end

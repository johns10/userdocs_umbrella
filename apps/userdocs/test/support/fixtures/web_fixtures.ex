defmodule UserDocs.WebFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Web

  def page() do
    {:ok, object } =
      page_attrs(:valid)
      |> Web.create_page()
    object
  end

  def element(page, strategy) do
    {:ok, object } =
      element_attrs(:valid)
      |> Map.put(:page_id, page.id)
      |> Map.put(:strategy_id, strategy.id)
      |> Web.create_element()
    object
  end

  def strategy() do
    {:ok, strategy } =
      strategy_attrs(:valid)
      |> Web.create_strategy()
      strategy
  end

  def annotation(page) do
    {:ok, annotation } =
      annotation_attrs(:valid)
      |> Map.put(:page_id, page.id)
      |> Web.create_annotation()
    annotation
  end

  def page_attrs(:valid) do
    %{
      url: "some url",
      version_id: ""
    }
  end

  def element_attrs(:valid) do
    %{
      name: UUID.uuid4(),
      selector: UUID.uuid4()
    }
  end

  def strategy_attrs(:valid) do
    %{
      name: "strategy"
    }
  end

  def annotation_attrs(:valid) do
    %{
      label: "some label",
      name: UUID.uuid4()
    }
  end

end

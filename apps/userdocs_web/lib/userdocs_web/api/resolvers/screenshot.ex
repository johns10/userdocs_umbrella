defmodule UserDocsWeb.API.Resolvers.Screenshot do

  alias UserDocs.Media.Screenshot
  alias UserDocs.Screenshots
  alias UserDocs.Automation.Step
  alias UserDocs.Authorization

  def get_screenshot!(%Step{screenshot: %Screenshot{} = screenshot}, _args, _resolution) do
    {:ok, screenshot}
  end
  def get_screenshot!(%Step{screenshot: nil}, _args, _resolution) do
    IO.puts("Get element call where the parent is step, and the screenshot_id is nil")
    {:ok, nil}
  end

  def update_screenshot(_parent, %{id: id} = args, %{context: context}) do
    Authorization.check(%Screenshot{id: id}, context) do
      fn() ->
        Screenshots.get_screenshot!(id)
        |> Screenshots.update_screenshot(args)
      end
    end
  end

  def delete_screenshot(_parent, %{id: id}, %{context: context}) do
    Authorization.check(%Screenshot{id: id}, context) do
      fn() ->
        Screenshots.get_screenshot!(id)
        |> Screenshots.delete_screenshot()
      end
    end
  end

  def create_screenshot(_parent, %{step_id: step_id} = args, %{context: context}) do
    Authorization.check(%Step{id: step_id}, context) do
      fn() ->
        case Screenshots.create_screenshot(map_base64(args)) do
          {:ok, initial_screenshot} -> {:ok, initial_screenshot}
          {:error, %Ecto.Changeset{changes: %{step_id: step_id}, errors: [step_id: {"has already been taken", _}]}} ->
            Screenshots.get_screenshot_by_step_id!(step_id)
            |> Screenshots.update_screenshot(args)

          {:error, changeset} -> {:error, UserDocs.ChangesetHelpers.changeset_error_to_string(changeset)}
        end
      end
    end
  end

  def map_base64(args) do
    args
    |> Map.put(:base64, args.base64)
    |> Map.delete(:base64)
  end

end

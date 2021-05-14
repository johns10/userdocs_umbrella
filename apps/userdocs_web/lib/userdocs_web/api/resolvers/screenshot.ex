defmodule UserDocsWeb.API.Resolvers.Screenshot do

  alias UserDocs.Media.Screenshot
  alias UserDocs.Screenshots
  alias UserDocs.Automation.Step
  alias UserDocs.Users
  alias UserDocs.Authorization

  def get_screenshot!(%Step{ screenshot: %Screenshot{} = screenshot }, _args, _resolution) do
    { :ok, screenshot }
  end
  def get_screenshot!(%Step{ screenshot: nil }, _args, _resolution) do
    IO.puts("Get element call where the parent is step, and the screenshot_id is nil")
    { :ok, nil }
  end

  def update_screenshot(_parent, %{ id: id } = args, %{ context: context }) do
    IO.puts("Update Screenshot")
    Authorization.check(%Screenshot{ id: id }, context) do
      fn() ->
        Screenshots.get_screenshot!(id)
        |> Screenshots.update_screenshot(map_base_64(args))
      end
    end
  end

  def delete_screenshot(_parent, %{ id: id }, %{ context: context }) do
    Authorization.check(%Screenshot{ id: id }, context) do
      fn() ->
        Screenshots.get_screenshot!(id)
        |> Screenshots.delete_screenshot()
      end
    end
  end

  def create_screenshot(_parent, %{ step_id: step_id } = args, %{ context: context }) do
    Authorization.check(%Step{ id: step_id }, context) do
      fn() ->
        case Screenshots.create_screenshot(map_base_64(args)) do
          { :ok, initial_screenshot } -> { :ok, initial_screenshot }
          { :error, changeset } -> { :error, UserDocs.ChangesetHelpers.changeset_error_to_string(changeset) }
        end
      end
    end
  end

  def map_base_64(args) do
    args
    |> Map.put(:base_64, args.base64)
    |> Map.delete(:base64)
  end

end

defmodule UserDocs.Users.LocalOptions do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:image_path, :max_retries, :user_data_dir_path]}
  schema "local_options" do
    field :image_path, :string
    field :max_retries, :integer
    field :user_data_dir_path, :string
  end

  @doc false
  def changeset(local_options, attrs) do
    local_options
    |> cast(attrs, [:image_path, :max_retries, :user_data_dir_path])
  end
end

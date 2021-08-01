defmodule UserDocsWeb.SessionLive.FormComponent do
  @moduledoc """
  Form for signing in to userdocs
  """
  use UserDocsWeb, :live_component

  alias UserDocs.Users

  @impl true
  def update(%{user: user, trigger_submit: trigger_submit} = assigns, socket) do
    changeset = Users.change_user(user)
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:trigger_submit, trigger_submit)
    }
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Users.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Users.validate_signin(user_params) do
      {:ok, changeset} ->
        {:ok, user} = Ecto.Changeset.apply_action(changeset, :insert)
        {
          :noreply,
          socket
          |> assign(:user, user)
          |> assign(:changeset, changeset)
          |> assign(:trigger_submit, true)
          |> push_event("login-sent", %{})
        }

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end

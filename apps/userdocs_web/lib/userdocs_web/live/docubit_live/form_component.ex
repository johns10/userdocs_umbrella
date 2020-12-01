defmodule UserDocsWeb.DocubitLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Documents
  alias UserDocs.Documents.Docubit
  alias UserDocsWeb.Layout

  @impl true
  def update(%{docubit: docubit} = assigns, socket) do
    changeset = Documents.change_docubit(docubit)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
    }
  end
end

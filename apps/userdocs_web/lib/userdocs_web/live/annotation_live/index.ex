defmodule UserDocsWeb.AnnotationLive.Index do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper


  alias UserDocs.Web
  alias UserDocs.Web.Annotation

  @impl true
  def mount(_params, session, socket) do
    {:ok,
      socket
      |> maybe_assign_current_user(session)
      |> assign(:annotations, list_annotations())
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Annotation")
    |> assign(:annotation, Web.get_annotation!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Annotation")
    |> assign(:annotation, %Annotation{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Annotations")
    |> assign(:annotation, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    annotation = Web.get_annotation!(id)
    {:ok, _} = Web.delete_annotation(annotation)

    {:noreply, assign(socket, :annotations, list_annotations())}
  end

  defp list_annotations do
    Web.list_annotations(%{content: true})
  end
end

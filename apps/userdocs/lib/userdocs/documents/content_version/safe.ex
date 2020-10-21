defmodule UserDocs.Documents.ContentVersion.Safe do
  def apply(content, handlers \\ %{})
  def apply(content_version = %UserDocs.Documents.ContentVersion{}, _handlers) do
    base_safe(content_version)
  end
  def apply(nil, _), do: nil

  defp base_safe(content_version = %UserDocs.Documents.ContentVersion{}) do
    %{
      id: content_version.id,
      name: content_version.name,
      body: content_version.body,
      version_id: content_version.version_id,
      language_code_id: content_version.language_code_id
    }
  end
end

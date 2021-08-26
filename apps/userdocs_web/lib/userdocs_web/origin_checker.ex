defmodule UserDocsWeb.OriginChecker do
  @moduledoc false
  def check(%URI{scheme: "https", host: "dev.user-docs.com", port: _}, :dev), do: true
  def check(%URI{scheme: "https", host: "dev.user-docs.com", port: _}, :integration), do: true
  def check(%URI{scheme: "https", host: "app.user-docs.com", port: _}, :prod), do: true
  def check(%URI{scheme: "chrome-extension", host: _, port: _}, :dev), do: true
  def check(%URI{scheme: "chrome-extension", host: _, port: _}, :integration), do: true
  def check(%URI{scheme: "chrome-extension", host: _, port: _}, :prod), do: true
end

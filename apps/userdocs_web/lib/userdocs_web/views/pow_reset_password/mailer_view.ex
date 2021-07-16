defmodule UserDocsWeb.PowResetPassword.MailerView do
  use UserDocsWeb, :mailer_view

  def subject(:reset_password, _assigns), do: "Reset password link"
end

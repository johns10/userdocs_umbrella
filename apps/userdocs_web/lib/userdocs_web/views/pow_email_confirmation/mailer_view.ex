defmodule UserDocsWeb.PowEmailConfirmation.MailerView do
  use UserDocsWeb, :mailer_view

  def subject(:email_confirmation, _assigns), do: "Confirm your email address"
end

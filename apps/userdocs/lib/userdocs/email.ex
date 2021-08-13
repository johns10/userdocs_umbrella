defmodule UserDocs.Email do
  @moduledoc false
  import Bamboo.Email
  use Bamboo.Template

  def confirmation_email(%{to: address, subject: subject, text: text, html: html}) do
    new_email()
    |> from("welcome@user-docs.com")
    |> subject(subject)
    |> html_body(html)
    |> text_body(text)
    |> to(address)
  end

  def cast_onboarding(%{user: user, invited_by: invited_by, module: module, url: url}) do
    %{
      to: user.email,
      subject: invited_by.email <> " has invited you to join UserDocs!",
      assigns: %{
        url: url,
        invited_by_email: invited_by.email
      },
      module: module
    }
  end

  def onboarding(%{to: address, subject: subject, module: module, assigns: %{invited_by_email: email, url: url}}) do
    new_email()
    |> from("welcome@user-docs.com")
    |> subject(subject)
    |> to(address)
    |> put_view(module)
    |> render(:invitation, %{invited_by_email: email, url: url})
  end

  def send(email) do
    UserDocs.Mailer.deliver_later(email)
  end
end

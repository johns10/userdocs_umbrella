defmodule UserDocs.Email do
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

  def send(email) do
    UserDocs.Mailer.deliver_later(email)
  end
end

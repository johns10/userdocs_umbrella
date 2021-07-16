defmodule UserDocsWeb.Pow.Mailer do
  use Pow.Phoenix.Mailer
  require Logger

  def cast(%{user: user, subject: subject, text: text, html: html, assigns: _assigns}) do
    %{to: user.email, subject: subject, text: text, html: html}
  end

  def process(email) do
    email
    |> UserDocs.Email.confirmation_email()
    |> IO.inspect()
    |> UserDocs.Email.send()
  end
end

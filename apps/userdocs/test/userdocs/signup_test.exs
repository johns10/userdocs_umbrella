defmodule UserDocs.SignupTest do
  use UserDocs.DataCase

  alias UserDocs.Email
  alias UserDocs.Mailer

  describe "signup" do

    test "signup test", %{} do
      #assert false
    end

    test "sends confirmation email", %{} do
      %{to: "test@test.com", subject: "test", text: "text", html: "<p>html</p>"}
      |> Email.confirmation_email()
      |> Mailer.deliver_now!()
    end
  end
end

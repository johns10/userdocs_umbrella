defmodule UserDocsWeb.SignupLiveTest do
  use UserDocsWeb.ConnCase
  import Phoenix.LiveViewTest
  alias UserDocs.UsersFixtures
  use Bamboo.Test
  require EEx

  describe "Signup" do

    test "signup form renders correctly", %{conn: conn} do
      {:ok, index_live, html} = live(conn, Routes.signup_index_path(conn, :new))

      assert html =~ "Sign Up"
      assert html =~ "Email"
    end

    test "creates new user", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.signup_index_path(conn, :new))

      invalid_attrs = %{email: "test@test.com", password: "asdf", password_confirmation: "asdf1234asdf"}

      assert index_live
      |> form("#signup-form", user: %{email: nil})
      |> render_change() =~ "can&#39;t be blank"

      assert index_live
      |> form("#signup-form", user: %{email: "test@test.com"})
      |> render_change() =~ "can&#39;t be blank"

      assert index_live
      |> form("#signup-form", user: %{email: "test@test.com", password: "asdf1234asdf"})
      |> render_change() =~ "does not match confirmation"

      assert index_live
      |> form("#signup-form", user: invalid_attrs)
      |> render_change() =~ "does not match confirmation"

      valid_attrs = UsersFixtures.user_attrs(:valid)

      form = form(index_live, "#signup-form", user: valid_attrs)
      render_submit(form)

      conn = follow_trigger_action(form, conn)

      assert conn.method == "POST"
      assert conn.params["user"]["email"] == valid_attrs.email

      html_template_path = Path.join(File.cwd!, "/lib/userdocs_web/templates/pow_email_confirmation/mailer/email_confirmation.html.eex")
      text_template_path = Path.join(File.cwd!, "/lib/userdocs_web/templates/pow_email_confirmation/mailer/email_confirmation.text.eex")

      email_attrs = %{
        to: valid_attrs.email,
        subject: "Welcome to UserDocs",
        text: EEx.eval_file(text_template_path, [assigns: %{url: ""}]),
        html: EEx.eval_file(html_template_path, [assigns: %{url: ""}])
      }

      expected_email = UserDocs.Email.confirmation_email(email_attrs)

      assert "/setup/" <> _user_id = redir_path = redirected_to(conn, 302)
      conn = get(recycle(conn), redir_path)
    end
  end
end

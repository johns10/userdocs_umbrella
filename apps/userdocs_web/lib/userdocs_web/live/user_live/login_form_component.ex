defmodule UserDocsWeb.UserLive.LoginFormComponent do
  use UserDocsWeb, :live_slime_component

  def render(assigns, path) do
    ~L"""
    section.hero.is-primary.is-fullheight
      .hero-body
        .container
          .columns.is-centered
            .column.is-10-tablet.is-8-desktop.is-6-widescreen
              = form_for @changeset, path, [class: "box", as: :user], fn f ->
                .field
                = label f, Pow.Ecto.Schema.user_id_field(@changeset), class: "label"
                  .control.has-icons-left
                    = email_input f, Pow.Ecto.Schema.user_id_field(@changeset), class: "input"
                    span.icon.is-small.is-left
                      i.fa.fa-envelope
                .field
                  = label f, :password, class: "label"
                  .control.has-icons-left
                    = password_input f, :password, class: "input"
                    = error_tag f, :password
                    span.icon.is-small.is-left
                      i.fa.fa-lock
                .field
                  = submit "Sign in", class: "button is-success"
            </form>
    """
  end
end

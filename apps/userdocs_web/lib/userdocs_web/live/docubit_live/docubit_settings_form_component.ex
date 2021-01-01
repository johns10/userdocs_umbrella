defmodule UserDocsWeb.DocubitSettingsLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocsWeb.Layout
  alias UserDocs.Documents
  alias UserDocs.Documents.DocubitSetting, as: DocubitSettings

  def render_fields(assigns, form) do
    ~L"""
    <p class="subtitle mb-1">Effective Settings</p>
    <%= inspect(@docubit.settings) %>
    <%= inspect(@settings_to_display) %>
    <div class="field ml-2">
      <div class="control">
        <%= for { name, value } <- @docubit.context.settings |> Map.take(DocubitSettings.__schema__(:fields)) do %>
          <%= if value do %>
            <p>
              <%= name %>: <%= value %>
            </p>
          <% end %>
        <% end %>
      </div>
    </div>
    <%= Layout.text_input(form, :li_value, [ hidden: :li_value not in @settings_to_display ]) %>
    <%= Layout.select_input(form, :name_prefix, setting_select_options(:name_prefix),
      [ hidden: :name_prefix not in @settings_to_display ]) %>
    <%= Layout.select_input(form, :show_title, setting_select_options(:show_title),
      [ hidden: :show_title not in @settings_to_display ]) %>
    <div class="field">
      <div class="control">
        <%= if @display_settings_dropdown do %>
          <%= add_setting_options(assigns) %>
        <% else %>
          <%= add_setting_button(assigns) %>
        <% end %>
      </div>
    </div>
    """
  end

  def add_setting_button(assigns) do
    ~L"""
      <a class="button"
        aria-haspopup="true"
        aria-controls="dropdown-menu"
        phx-click="display-setting-menu"
        phx-target="<%= @myself.cid %>"
      >+</a>
    """
  end

  def add_setting_options(assigns) do
    ~L"""
      <label class="label">Add a Setting</label>
      <div class="buttons">
        <%= for allowed_setting <- @docubit.docubit_type.allowed_settings do %>
          <a class="button"
            phx-click="add-setting"
            phx-value-type=<%= allowed_setting %>
            phx-target=<%= @myself.cid %>
          ><%= allowed_setting %></a>
        <% end %>
        <a class="button"
          aria-haspopup="true"
          aria-controls="dropdown-menu"
          phx-click="display-setting-menu"
          phx-target="<%= @myself.cid %>"
        >-</a>
      </div>
    """
  end

  @impl true
  def update(%{document: document} = assigns, socket) do
    { :ok, socket }
  end

  def setting_select_options(key) do
    setting_param(key)
    |> Map.get(:select_options)
  end

  def setting_param(key) do
    Kernel.apply(DocubitSettings, key, [])
  end
end

module SettingsHelper

  def default_allow_editor
    current_admin.present?
  end

  def edit_mode
    @admin_edit_mode || params[:admin_edit_mode]
  end

  def settings_helper key, options = {}, &block
    options[:condition] ||= default_allow_editor()

    if block_given?
      if edit_mode
        content_tag :span, class: "admin_edit" do
          icon(:edit) + yield
        end
      else
        yield
      end
    end
  end

  def settings_text key, options = {}
    settings_helper key, options do
      SettingsModel.instance.set_default(key, options[:default])
      best_in_place_if options[:condition], SettingsModel.instance, key, url: admins_setting_path(key)
    end
  end

  def settings_textarea key, options = {}
    settings_helper key, options do
      SettingsModel.instance.set_default(key, options[:default])
      best_in_place_if options[:condition], SettingsModel.instance, key, url: admins_setting_path(key), display_with: :raw, :as => :textarea
    end
  end

  def settings_image key, options = {}
    image_options = %i(size alt width height class)
    helper_options = options.extract!(*image_options)
    settings_helper key, options do
      SettingsModel.instance.set_default(key, options[:default])
      best_in_place_if options[:condition], SettingsModel.instance, key, url: admins_setting_path(key), display_with: :image_tag, helper_options: helper_options, as: :image
    end
  end

  def settings_button key, options = {}
    button_options = %i(url context class)
    helper_options = options.extract!(*button_options)

    settings_helper key, options do
      SettingsModel.instance.set_default(key, options[:default])
      best_in_place_if options[:condition], SettingsModel.instance, key, url: admins_setting_path(key), display_with: :button, helper_options: helper_options
    end
  end
end

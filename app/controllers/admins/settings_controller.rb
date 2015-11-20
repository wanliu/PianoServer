class Admins::SettingsController < Admins::BaseController

  def update
    key = params[:id]
    value = settings_params[params[:id]]

    settings = load_settings

    set_keys settings, key, value

    save_settings(settings)

    render nothing: true
  end

  private

  def settings_path
    Rails.root.join('config/settings')
  end

  def settings_file
    File.join(settings_path, [Rails.env, 'local', 'yml'].join('.'))
  end

  def settings_params
    params[:settings_model]
  end

  def load_settings
    YAML.load_file(settings_file)
  rescue Errno::ENOENT
    {}
  end

  def save_settings(settings)
    File.open(settings_file, 'w') {|f| f.write settings.to_yaml }
  rescue
    nil
  end

  def set_keys(settings, key, value)
    keys = key.split('.')

    i = 0
    last = keys.inject(settings) do |s, key|
      i+=1
      if s[key].nil?
        s[key] = {}
      else
        s[key]
      end
      if i == keys.length
        s[key] = value
      else
        s[key]
      end
    end
  end
end

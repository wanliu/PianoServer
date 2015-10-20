require "yaml"

email = YAML.load_file("config/email.yml")[::Rails.env]

ActionMailer::Base.smtp_settings = {
    :address => email["address"],
    :port => email["port"],
    :domain => email["domain"],
    :authentication => "plain",
    :user_name => email["user_name"],
    :password => email["password"],
    :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options = {
    :host => email["url_host"],
    :port => email["url_port"]
}

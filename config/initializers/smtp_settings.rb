OneCms::Application.config.action_mailer.default_url_options = { host: Setting.site_host }
OneCms::Application.config.action_mailer.raise_delivery_errors = true
OneCms::Application.config.action_mailer.delivery_method = :smtp
OneCms::Application.config.action_mailer.smtp_settings = Setting.smtp_settings.symbolize_keys
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE if Rails.env.development?

# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider :wechat, Setting.wechat.app_id, Setting.wechat.app_secret, callback_path: '/wechat/callback'
# end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :wechat_web, Setting.wechat.app_id, Setting.wechat.app_secret, callback_path: '/wechat/callback', scope: 'snsapi_login'
end


# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(
  admin/app.js
  admin/app.css
  html5shiv.js
  swiper.js
  swiper.css
  tt/app.css
  tt/views/index.css
  tt/app.js
  tt/index.js
  tt/node_index.js
  tt/article.js
  tt/comment.js
  tt/sign_up.js
  tt_mobile/app.js
  tt_mobile/app.css
  tt/views/article.css
  tt/views/node.css
  jquery.slideBox.js
  jquery.slideBox.css
)

Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf)\z/

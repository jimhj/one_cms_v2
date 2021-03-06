# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180412133221) do

  create_table "active_tokens", force: :cascade do |t|
    t.string   "receiver",   limit: 255,               null: false
    t.string   "token",      limit: 255,               null: false
    t.integer  "state",      limit: 4,     default: 0
    t.text     "extras",     limit: 65535
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "admin_users", force: :cascade do |t|
    t.string   "login",           limit: 30,  null: false
    t.string   "name",            limit: 255
    t.string   "password_digest", limit: 255
    t.datetime "last_login_time"
    t.string   "last_login_ip",   limit: 255
    t.string   "login_ip",        limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "article_bodies", force: :cascade do |t|
    t.integer "article_id",        limit: 4,                 null: false
    t.text    "body",              limit: 65535
    t.text    "body_html",         limit: 65535
    t.integer "cached_keyword_id", limit: 4,     default: 0
    t.string  "redirect_url",      limit: 2083
  end

  add_index "article_bodies", ["article_id"], name: "index_article_bodies_on_article_id", using: :btree

  create_table "articles", force: :cascade do |t|
    t.integer  "user_id",         limit: 4,   default: 0,     null: false
    t.integer  "node_id",         limit: 4,                   null: false
    t.string   "title",           limit: 200,                 null: false
    t.string   "short_title",     limit: 80
    t.integer  "comments_count",  limit: 4,   default: 0
    t.integer  "sort_rank",       limit: 4,   default: 0
    t.string   "color",           limit: 10
    t.string   "writer",          limit: 20
    t.string   "thumb",           limit: 255
    t.string   "source",          limit: 30
    t.string   "seo_title",       limit: 255
    t.string   "seo_keywords",    limit: 255
    t.string   "seo_description", limit: 255
    t.boolean  "approved",                    default: true
    t.boolean  "focus",                       default: false
    t.integer  "hits",            limit: 4,   default: 0
    t.boolean  "secondary_focus",             default: false
    t.boolean  "hot",                         default: false
    t.boolean  "recommend",                   default: false
    t.integer  "status",          limit: 4,   default: 0
    t.boolean  "linked",                      default: false
    t.string   "link_word",       limit: 255
    t.integer  "pictures_count",  limit: 4,   default: -1
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "articles", ["focus"], name: "index_articles_on_focus", using: :btree
  add_index "articles", ["hot"], name: "index_articles_on_hot", using: :btree
  add_index "articles", ["node_id", "approved"], name: "index_articles_on_node_id_and_approved", using: :btree
  add_index "articles", ["node_id"], name: "index_articles_on_node_id", using: :btree
  add_index "articles", ["pictures_count"], name: "index_articles_on_pictures_count", using: :btree
  add_index "articles", ["secondary_focus"], name: "index_articles_on_secondary_focus", using: :btree
  add_index "articles", ["thumb"], name: "index_articles_on_thumb", using: :btree
  add_index "articles", ["title"], name: "index_articles_on_title", using: :btree
  add_index "articles", ["user_id"], name: "index_articles_on_user_id", using: :btree

  create_table "channel_articles", force: :cascade do |t|
    t.integer  "channel_id", limit: 4
    t.integer  "article_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "channel_articles", ["article_id"], name: "index_channel_articles_on_article_id", using: :btree
  add_index "channel_articles", ["channel_id"], name: "index_channel_articles_on_channel_id", using: :btree

  create_table "channels", force: :cascade do |t|
    t.string   "name",            limit: 255,                null: false
    t.string   "slug",            limit: 255,                null: false
    t.string   "seo_keywords",    limit: 255
    t.string   "seo_description", limit: 255
    t.integer  "sortrank",        limit: 4,   default: 1000
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "channels", ["slug"], name: "index_channels_on_slug", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.integer  "article_id",  limit: 4
    t.integer  "to_user_id",  limit: 4
    t.integer  "reply_to_id", limit: 4
    t.text     "content",     limit: 65535
    t.boolean  "approved",                  default: true
    t.text     "extras",      limit: 65535
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "comments", ["article_id"], name: "index_comments_on_article_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "hot_articles", force: :cascade do |t|
    t.string   "title",      limit: 200,                null: false
    t.string   "link",       limit: 255,                null: false
    t.integer  "sortrank",   limit: 4,   default: 1000
    t.boolean  "active",                 default: true
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "keywords", force: :cascade do |t|
    t.string   "name",       limit: 100,                null: false
    t.string   "url",        limit: 100,                null: false
    t.integer  "sortrank",   limit: 4,   default: 1000
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "keywords", ["id", "sortrank"], name: "index_keywords_on_id_and_sortrank", using: :btree
  add_index "keywords", ["sortrank"], name: "index_keywords_on_sortrank", using: :btree

  create_table "links", force: :cascade do |t|
    t.integer  "linkable_id",   limit: 4
    t.string   "linkable_type", limit: 255
    t.string   "name",          limit: 30,                  null: false
    t.string   "title",         limit: 150
    t.string   "url",           limit: 150,                 null: false
    t.string   "qq",            limit: 20
    t.integer  "sortrank",      limit: 4,   default: 1000
    t.integer  "status",        limit: 4,   default: 0
    t.string   "device",        limit: 255, default: "PC"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "nofollow",                  default: false
  end

  add_index "links", ["linkable_type", "linkable_id"], name: "index_links_on_linkable_type_and_linkable_id", using: :btree

  create_table "nodes", force: :cascade do |t|
    t.string   "name",            limit: 30,                    null: false
    t.string   "slug",            limit: 30,                    null: false
    t.integer  "parent_id",       limit: 4
    t.integer  "lft",             limit: 4,     default: 0
    t.integer  "rgt",             limit: 4,     default: 0
    t.integer  "depth",           limit: 4,     default: 0
    t.integer  "children_count",  limit: 4,     default: 0
    t.string   "seo_title",       limit: 255
    t.string   "seo_keywords",    limit: 255
    t.string   "seo_description", limit: 255
    t.integer  "sortrank",        limit: 4,     default: 1000
    t.boolean  "is_nav",                        default: false
    t.boolean  "is_column",                     default: false
    t.boolean  "is_shown",                      default: true
    t.boolean  "is_at_top",                     default: true
    t.string   "logo",            limit: 255
    t.string   "nav_name",        limit: 255
    t.string   "nav_color",       limit: 255
    t.text     "extras",          limit: 65535
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "nodes", ["depth"], name: "index_nodes_on_depth", using: :btree
  add_index "nodes", ["lft"], name: "index_nodes_on_lft", using: :btree
  add_index "nodes", ["parent_id"], name: "index_nodes_on_parent_id", using: :btree
  add_index "nodes", ["rgt"], name: "index_nodes_on_rgt", using: :btree

  create_table "redactor_assets", force: :cascade do |t|
    t.string   "data_file_name",    limit: 255, null: false
    t.string   "data_content_type", limit: 255
    t.integer  "data_file_size",    limit: 4
    t.integer  "assetable_id",      limit: 4
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "redactor_assets", ["assetable_type", "assetable_id"], name: "idx_redactor_assetable", using: :btree
  add_index "redactor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_redactor_assetable_type", using: :btree
  add_index "redactor_assets", ["data_file_name"], name: "index_redactor_assets_on_data_file_name", using: :btree

  create_table "site_ads", force: :cascade do |t|
    t.string   "key",        limit: 255,                  null: false
    t.string   "title",      limit: 255
    t.text     "value",      limit: 65535,                null: false
    t.integer  "sortrank",   limit: 4,     default: 50
    t.boolean  "active",                   default: true
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "site_ads", ["key"], name: "index_site_ads_on_key", using: :btree

  create_table "site_configs", force: :cascade do |t|
    t.string  "site_name",        limit: 255,                  null: false
    t.string  "site_slogan",      limit: 255
    t.string  "site_title",       limit: 255,                  null: false
    t.string  "site_keywords",    limit: 255
    t.string  "site_description", limit: 255
    t.string  "site_logo",        limit: 255
    t.string  "mobile_logo",      limit: 255
    t.string  "favicon",          limit: 255
    t.text    "extras",           limit: 65535
    t.boolean "active",                         default: true
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "article_id", limit: 4
    t.integer  "tag_id",     limit: 4
    t.datetime "created_at"
  end

  add_index "taggings", ["article_id", "tag_id"], name: "index_taggings_on_article_id_and_tag_id", using: :btree
  add_index "taggings", ["article_id"], name: "index_taggings_on_article_id", using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",            limit: 30,              null: false
    t.string   "slug",            limit: 80,              null: false
    t.string   "seo_title",       limit: 255
    t.string   "seo_keywords",    limit: 255
    t.string   "seo_description", limit: 255
    t.integer  "taggings_count",  limit: 4,   default: 0
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "tags", ["slug"], name: "index_tags_on_slug", using: :btree
  add_index "tags", ["taggings_count"], name: "index_tags_on_taggings_count", using: :btree

  create_table "token_hongbaos", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "token_id",   limit: 4
    t.float    "amount",     limit: 24,    default: 0.0
    t.text     "extras",     limit: 65535
    t.boolean  "opened",                   default: false
    t.string   "from",       limit: 255,   default: "sign_up"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "token_hongbaos", ["token_id"], name: "index_token_hongbaos_on_token_id", using: :btree
  add_index "token_hongbaos", ["user_id"], name: "index_token_hongbaos_on_user_id", using: :btree

  create_table "token_withdraws", force: :cascade do |t|
    t.integer  "user_token_id", limit: 4
    t.float    "amount",        limit: 24
    t.integer  "state",         limit: 4,     default: 0
    t.text     "extras",        limit: 65535
    t.string   "address",       limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "tokens", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "code",                 limit: 255
    t.float    "total",                limit: 24,                null: false
    t.integer  "hongbao_number",       limit: 4,     default: 0, null: false
    t.float    "available_total",      limit: 24,                null: false
    t.string   "hongbao_amount_range", limit: 255
    t.datetime "start_time"
    t.datetime "end_time"
    t.text     "token_desc",           limit: 65535
    t.string   "official_site",        limit: 255
    t.text     "gift_words",           limit: 65535
    t.text     "qr_code",              limit: 65535
    t.string   "token_logo",           limit: 255
    t.text     "extras",               limit: 65535
    t.integer  "actived",              limit: 1,     default: 1
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "user_credit_logs", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.integer  "comments_count", limit: 4,     default: 0
    t.integer  "articles_count", limit: 4,     default: 0
    t.integer  "daily_credits",  limit: 4,     default: 0
    t.integer  "log_day",        limit: 4,     default: 0
    t.integer  "login_number",   limit: 4,     default: 0
    t.boolean  "logged",                       default: false
    t.text     "extras",         limit: 65535
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "user_credit_logs", ["user_id"], name: "index_user_credit_logs_on_user_id", using: :btree

  create_table "user_tokens", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "token_id",   limit: 4
    t.float    "amount",     limit: 24
    t.text     "extras",     limit: 65535
    t.string   "address",    limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",               limit: 255,                  null: false
    t.string   "mobile",              limit: 255
    t.string   "username",            limit: 255,                  null: false
    t.string   "password_digest",     limit: 255,                  null: false
    t.string   "private_token",       limit: 255
    t.string   "avatar",              limit: 255
    t.datetime "remember_created_at"
    t.integer  "state",               limit: 4,     default: 0
    t.integer  "sign_in_count",       limit: 4,     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",  limit: 255
    t.string   "last_sign_in_ip",     limit: 255
    t.string   "allowed_node_ids",    limit: 255
    t.boolean  "review_later",                      default: true
    t.text     "extras",              limit: 65535
    t.integer  "credits",             limit: 4,     default: 0
    t.integer  "login_number",        limit: 4,     default: 0
    t.string   "wx_openid",           limit: 255
    t.string   "wx_unionid",          limit: 255
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

end

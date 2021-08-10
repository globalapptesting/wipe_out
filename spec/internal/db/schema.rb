# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "reset_password_token"
    t.string "access_tokens"
    t.datetime "confirmed_at"
    t.integer "sign_in_count"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "user_id"
    t.string "value"
  end

  create_table "resource_files", force: :cascade do |t|
    t.integer "comment_id"
  end

  create_table "dashboards", force: :cascade do |t|
    t.integer "user_id"
    t.string "order"
  end
end

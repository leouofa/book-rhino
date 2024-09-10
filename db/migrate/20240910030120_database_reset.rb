class DatabaseReset < ActiveRecord::Migration[7.2]
  def change
    enable_extension "pgcrypto"
    enable_extension "plpgsql"
    enable_extension "vector"

    create_table "settings", force: :cascade do |t|
      t.text "prompts"
      t.text "tunings"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.time "publish_start_time", default: "2000-01-01 08:00:00"
      t.time "publish_end_time", default: "2000-01-01 21:00:00"
    end

    create_table "locks", force: :cascade do |t|
      t.string "name", null: false
      t.boolean "locked", default: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["name"], name: "index_locks_on_name", unique: true
    end

    create_table "users", force: :cascade do |t|
      t.string "email", default: "", null: false
      t.string "encrypted_password", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer "sign_in_count", default: 0, null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string "current_sign_in_ip"
      t.string "last_sign_in_ip"
      t.string "confirmation_token"
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.string "unconfirmed_email"
      t.integer "failed_attempts", default: 0, null: false
      t.string "unlock_token"
      t.datetime "locked_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "has_access", default: false
      t.boolean "admin", default: false
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    end
  end
end

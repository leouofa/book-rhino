# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_02_22_195751) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "vector"

  create_table "archetypes", force: :cascade do |t|
    t.string "name"
    t.text "traits"
    t.text "examples"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "archetypes_characters", id: false, force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "archetype_id", null: false
    t.index ["archetype_id", "character_id"], name: "index_archetypes_characters_on_archetype_id_and_character_id"
    t.index ["character_id", "archetype_id"], name: "index_archetypes_characters_on_character_id_and_archetype_id"
  end

  create_table "book_antagonists", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "character_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id", "character_id"], name: "index_book_antagonists_on_book_id_and_character_id", unique: true
    t.index ["book_id"], name: "index_book_antagonists_on_book_id"
    t.index ["character_id"], name: "index_book_antagonists_on_character_id"
  end

  create_table "books", force: :cascade do |t|
    t.text "title"
    t.bigint "writing_style_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "perspective_id"
    t.text "moral"
    t.text "plot"
    t.integer "chapter_count"
    t.integer "pages"
    t.bigint "narrative_structure_id"
    t.bigint "protagonist_id"
    t.boolean "pending"
    t.index ["narrative_structure_id"], name: "index_books_on_narrative_structure_id"
    t.index ["perspective_id"], name: "index_books_on_perspective_id"
    t.index ["protagonist_id"], name: "index_books_on_protagonist_id"
    t.index ["writing_style_id"], name: "index_books_on_writing_style_id"
  end

  create_table "books_characters", id: false, force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "character_id", null: false
    t.index ["book_id", "character_id"], name: "index_books_characters_on_book_id_and_character_id"
    t.index ["character_id", "book_id"], name: "index_books_characters_on_character_id_and_book_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.integer "number", null: false
    t.text "summary", null: false
    t.text "content", null: false
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id", "number"], name: "index_chapters_on_book_id_and_number", unique: true
    t.index ["book_id"], name: "index_chapters_on_book_id"
  end

  create_table "character_types", force: :cascade do |t|
    t.string "name"
    t.text "definition"
    t.text "purpose"
    t.text "example"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "character_types_characters", id: false, force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "character_type_id", null: false
    t.index ["character_id", "character_type_id"], name: "idx_on_character_id_character_type_id_432f58b042"
    t.index ["character_type_id", "character_id"], name: "idx_on_character_type_id_character_id_a9c66b3fa3"
  end

  create_table "characters", force: :cascade do |t|
    t.string "name"
    t.string "gender"
    t.bigint "age"
    t.string "ethnicity"
    t.string "nationality"
    t.text "appearance"
    t.text "health"
    t.text "fears"
    t.text "desires"
    t.text "backstory"
    t.text "skills"
    t.text "values"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "prompt"
    t.boolean "pending"
  end

  create_table "characters_locations", force: :cascade do |t|
    t.bigint "character_id"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_characters_locations_on_character_id"
    t.index ["location_id"], name: "index_characters_locations_on_location_id"
  end

  create_table "characters_moral_alignments", id: false, force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "moral_alignment_id", null: false
    t.index ["character_id", "moral_alignment_id"], name: "idx_on_character_id_moral_alignment_id_110fe45616"
    t.index ["moral_alignment_id", "character_id"], name: "idx_on_moral_alignment_id_character_id_b452e3076d"
  end

  create_table "characters_personality_traits", id: false, force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "personality_trait_id", null: false
    t.index ["character_id", "personality_trait_id"], name: "idx_on_character_id_personality_trait_id_bde1d5670b"
    t.index ["personality_trait_id", "character_id"], name: "idx_on_personality_trait_id_character_id_aa8c32a6c8"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.text "lighting"
    t.text "time"
    t.text "noise_level"
    t.text "comfort"
    t.text "aesthetics"
    t.text "accessibility"
    t.text "personalization"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "region_id"
    t.text "description"
    t.text "prompt"
    t.boolean "pending"
    t.index ["region_id"], name: "index_locations_on_region_id"
  end

  create_table "locks", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "locked", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_locks_on_name", unique: true
  end

  create_table "moral_alignments", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "examples"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_moral_alignments_on_name", unique: true
  end

  create_table "narrative_structures", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "parts"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_narrative_structures_on_name", unique: true
  end

  create_table "personality_traits", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "perspectives", force: :cascade do |t|
    t.string "name"
    t.text "narrator"
    t.text "pronouns"
    t.text "effect"
    t.text "example"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "regions", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "country"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state"
  end

  create_table "settings", force: :cascade do |t|
    t.text "prompts"
    t.text "tunings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "publish_start_time"
    t.datetime "publish_end_time"
  end

  create_table "texts", force: :cascade do |t|
    t.text "corpus"
    t.bigint "writing_style_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["writing_style_id"], name: "index_texts_on_writing_style_id"
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

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "writing_styles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "prompt"
    t.boolean "pending", default: false
  end

  add_foreign_key "book_antagonists", "books"
  add_foreign_key "book_antagonists", "characters"
  add_foreign_key "books", "characters", column: "protagonist_id"
  add_foreign_key "books", "narrative_structures"
  add_foreign_key "books", "perspectives"
  add_foreign_key "books", "writing_styles"
  add_foreign_key "chapters", "books"
  add_foreign_key "locations", "regions"
  add_foreign_key "texts", "writing_styles"
end

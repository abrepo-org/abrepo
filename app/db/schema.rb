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

ActiveRecord::Schema.define(version: 2021_08_12_203546) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.string "actionType"
    t.string "url"
    t.string "selector"
    t.integer "waitfor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "crawlId"
    t.string "a_id"
    t.string "selectorDisplayName"
  end

  create_table "audiences", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "experiment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["experiment_id"], name: "index_audiences_on_experiment_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name"
    t.bigint "experiment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "a_id"
    t.string "vendor_id"
    t.index ["experiment_id"], name: "index_campaigns_on_experiment_id"
  end

  create_table "diffs", force: :cascade do |t|
    t.string "selector"
    t.json "calculated"
    t.bigint "renderable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "newDim"
    t.json "origDim"
    t.string "diffType"
    t.string "a_id"
    t.string "crawlId"
    t.string "summary_delta"
    t.string "summary_added"
    t.string "summary_removed"
    t.string "selectorDisplayName"
    t.string "diffPanel", default: "true"
    t.string "group_id"
    t.string "viewMode"
    t.index ["renderable_id"], name: "index_diffs_on_renderable_id"
  end

  create_table "experiments", force: :cascade do |t|
    t.bigint "profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "domain"
    t.string "crawlId"
    t.string "a_id"
    t.string "vendor_id"
    t.string "summary_name"
    t.index ["profile_id"], name: "index_experiments_on_profile_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "domain"
    t.string "company_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "a_id"
    t.string "url"
  end

  create_table "related_profiles", force: :cascade do |t|
    t.integer "profile_id"
    t.integer "related_profile_id"
    t.index ["profile_id", "related_profile_id"], name: "index_related_profiles_on_profile_id_and_related_profile_id", unique: true
    t.index ["related_profile_id", "profile_id"], name: "index_related_profiles_on_related_profile_id_and_profile_id", unique: true
  end

  create_table "renderables", force: :cascade do |t|
    t.string "screenshotFilename"
    t.string "renderedURL"
    t.string "renderedTitle"
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "variation_id"
    t.bigint "action_id"
    t.boolean "control"
    t.bigint "renderable_id"
    t.string "a_id"
    t.string "crawlId"
    t.integer "screenshotWidth"
    t.integer "screenshotHeight"
    t.json "preExecuteAction"
    t.index ["action_id"], name: "index_renderables_on_action_id"
    t.index ["renderable_id"], name: "index_renderables_on_renderable_id"
    t.index ["variation_id"], name: "index_renderables_on_variation_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id"
    t.string "stripe_customer_id"
    t.boolean "active", default: false, null: false
    t.boolean "billing_issue", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "stripe_subscription_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "variations", force: :cascade do |t|
    t.bigint "experiment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.string "a_id"
    t.string "vendor_id"
    t.string "summary_name"
    t.boolean "verified", default: false, null: false
    t.index ["experiment_id"], name: "index_variations_on_experiment_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name"
    t.string "campaignID"
    t.string "variationID"
    t.string "variantID"
    t.bigint "experiment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "experimentID"
    t.bigint "variation_id"
    t.string "viewID"
    t.index ["experiment_id"], name: "index_vendors_on_experiment_id"
    t.index ["variation_id"], name: "index_vendors_on_variation_id"
  end

  add_foreign_key "audiences", "experiments"
  add_foreign_key "campaigns", "experiments"
  add_foreign_key "diffs", "renderables"
  add_foreign_key "experiments", "profiles"
  add_foreign_key "renderables", "actions"
  add_foreign_key "renderables", "variations"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "taggings", "tags"
  add_foreign_key "variations", "experiments"
  add_foreign_key "vendors", "experiments"
  add_foreign_key "vendors", "variations"
end

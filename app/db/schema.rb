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

ActiveRecord::Schema.define(version: 2019_12_04_190920) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.string "type"
    t.string "url"
    t.string "selector"
    t.integer "waitfor"
    t.bigint "variation_id"
    t.bigint "renderable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["renderable_id"], name: "index_actions_on_renderable_id"
    t.index ["variation_id"], name: "index_actions_on_variation_id"
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
    t.index ["experiment_id"], name: "index_campaigns_on_experiment_id"
  end

  create_table "experiments", force: :cascade do |t|
    t.string "name"
    t.bigint "profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "domain"
    t.string "crawlID"
    t.index ["profile_id"], name: "index_experiments_on_profile_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "domain"
    t.string "company_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "renderables", force: :cascade do |t|
    t.string "screenshotFilename"
    t.string "renderedURL"
    t.string "renderedTitle"
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "variations", force: :cascade do |t|
    t.string "name"
    t.bigint "experiment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "control"
    t.string "url"
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

  add_foreign_key "actions", "renderables"
  add_foreign_key "actions", "variations"
  add_foreign_key "audiences", "experiments"
  add_foreign_key "campaigns", "experiments"
  add_foreign_key "experiments", "profiles"
  add_foreign_key "variations", "experiments"
  add_foreign_key "vendors", "experiments"
  add_foreign_key "vendors", "variations"
end

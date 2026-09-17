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

ActiveRecord::Schema[8.1].define(version: 2026_09_17_090206) do
  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "customers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "contact"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.decimal "cost_price", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.decimal "selling_price", precision: 12, scale: 2, default: "0.0", null: false
    t.string "sku", null: false
    t.decimal "stock_quantity", precision: 12, scale: 2, default: "0.0", null: false
    t.string "unit", default: "pcs", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["sku"], name: "index_products_on_sku", unique: true
  end

  create_table "purchase_order_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.bigint "purchase_order_id", null: false
    t.decimal "quantity", precision: 12, scale: 2, null: false
    t.decimal "unit_cost", precision: 12, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_purchase_order_items_on_product_id"
    t.index ["purchase_order_id"], name: "index_purchase_order_items_on_purchase_order_id"
  end

  create_table "purchase_orders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "status", default: "draft", null: false
    t.bigint "supplier_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["status"], name: "index_purchase_orders_on_status"
    t.index ["supplier_id"], name: "index_purchase_orders_on_supplier_id"
    t.index ["user_id"], name: "index_purchase_orders_on_user_id"
  end

  create_table "sales_order_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.decimal "quantity", precision: 12, scale: 2, null: false
    t.bigint "sales_order_id", null: false
    t.decimal "unit_price", precision: 12, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_sales_order_items_on_product_id"
    t.index ["sales_order_id"], name: "index_sales_order_items_on_sales_order_id"
  end

  create_table "sales_orders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["customer_id"], name: "index_sales_orders_on_customer_id"
    t.index ["status"], name: "index_sales_orders_on_status"
    t.index ["user_id"], name: "index_sales_orders_on_user_id"
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "stock_movements", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "movement_type", null: false
    t.string "note"
    t.bigint "product_id", null: false
    t.decimal "quantity", precision: 12, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_stock_movements_on_created_at"
    t.index ["product_id"], name: "index_stock_movements_on_product_id"
    t.index ["user_id"], name: "index_stock_movements_on_user_id"
  end

  create_table "suppliers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "address"
    t.string "contact"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "products", "categories"
  add_foreign_key "purchase_order_items", "products"
  add_foreign_key "purchase_order_items", "purchase_orders"
  add_foreign_key "purchase_orders", "suppliers"
  add_foreign_key "purchase_orders", "users"
  add_foreign_key "sales_order_items", "products"
  add_foreign_key "sales_order_items", "sales_orders"
  add_foreign_key "sales_orders", "customers"
  add_foreign_key "sales_orders", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "stock_movements", "products"
  add_foreign_key "stock_movements", "users"
end

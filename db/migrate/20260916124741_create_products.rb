class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :sku, null: false
      t.string :unit, null: false, default: "pcs"
      t.decimal :cost_price, precision: 12, scale: 2, null: false, default: 0
      t.decimal :selling_price, precision: 12, scale: 2, null: false, default: 0
      t.decimal :stock_quantity, precision: 12, scale: 2, null: false, default: 0

      t.timestamps
    end
    add_index :products, :sku, unique: true
  end
end

class CreatePurchaseOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :purchase_order_items do |t|
      t.references :purchase_order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :quantity, precision: 12, scale: 2, null: false
      t.decimal :unit_cost, precision: 12, scale: 2, null: false

      t.timestamps
    end
  end
end

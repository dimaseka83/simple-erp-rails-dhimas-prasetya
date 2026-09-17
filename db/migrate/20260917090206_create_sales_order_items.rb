class CreateSalesOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :sales_order_items do |t|
      t.references :sales_order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :quantity, precision: 12, scale: 2, null: false
      t.decimal :unit_price, precision: 12, scale: 2, null: false

      t.timestamps
    end
  end
end

class CreatePurchaseOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :purchase_orders do |t|
      t.references :supplier, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "draft"

      t.timestamps
    end
    add_index :purchase_orders, :status
  end
end

class CreateStockMovements < ActiveRecord::Migration[8.1]
  def change
    create_table :stock_movements do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :movement_type, null: false
      t.decimal :quantity, precision: 12, scale: 2, null: false
      t.string :note

      t.timestamps
    end
    add_index :stock_movements, :created_at
  end
end

class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :settings do |t|
      t.string :currency, null: false, default: "idr"

      t.timestamps
    end
  end
end

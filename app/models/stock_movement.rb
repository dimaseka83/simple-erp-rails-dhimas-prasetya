class StockMovement < ApplicationRecord
  belongs_to :product
  belongs_to :user

  # Enum keys avoid `in`/`out` — `in?` would collide with ActiveSupport's
  # Object#in?, and the DB values stay the short "in"/"out" a reader expects.
  enum :movement_type, { stock_in: "in", stock_out: "out" }, validate: true

  validates :quantity, numericality: { greater_than: 0 }

  scope :search, ->(query) {
    next all if query.blank?
    like = "%#{sanitize_sql_like(query)}%"
    joins(:product).where("products.name LIKE :q OR stock_movements.note LIKE :q", q: like)
  }
end

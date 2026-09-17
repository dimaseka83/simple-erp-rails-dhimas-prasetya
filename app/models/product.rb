class Product < ApplicationRecord
  belongs_to :category
  has_many :stock_movements, dependent: :destroy

  enum :unit, { pcs: "pcs", kg: "kg", box: "box" }, default: "pcs", validate: true

  validates :name, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :cost_price, :selling_price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }

  scope :search, ->(query) {
    next all if query.blank?
    like = "%#{sanitize_sql_like(query)}%"
    where("name LIKE :q OR sku LIKE :q", q: like)
  }
end

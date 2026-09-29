class SalesOrder < ApplicationRecord
  belongs_to :customer
  belongs_to :user
  has_many :sales_order_items, dependent: :destroy
  accepts_nested_attributes_for :sales_order_items, allow_destroy: true, reject_if: :all_blank

  enum :status, { draft: "draft", confirmed: "confirmed" }, default: "draft", validate: true

  validates :sales_order_items, presence: true

  scope :search, ->(query) {
    next all if query.blank?
    like = "%#{sanitize_sql_like(query)}%"
    joins(:customer).where("customers.name LIKE :q OR sales_orders.id = :id", q: like, id: query.to_i)
  }
end

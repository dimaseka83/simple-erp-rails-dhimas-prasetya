class Supplier < ApplicationRecord
  has_many :purchase_orders, dependent: :restrict_with_error

  validates :name, presence: true

  scope :search, ->(query) {
    next all if query.blank?
    like = "%#{sanitize_sql_like(query)}%"
    where("name LIKE :q OR contact LIKE :q", q: like)
  }
end

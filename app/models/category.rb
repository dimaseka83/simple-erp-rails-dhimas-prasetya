class Category < ApplicationRecord
  has_many :products, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

  scope :search, ->(query) {
    next all if query.blank?
    where("name LIKE ?", "%#{sanitize_sql_like(query)}%")
  }
end

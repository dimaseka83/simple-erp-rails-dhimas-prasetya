class Customer < ApplicationRecord
  has_many :sales_orders, dependent: :restrict_with_error

  validates :name, presence: true
end

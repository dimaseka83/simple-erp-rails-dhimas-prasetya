class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :stock_movements, dependent: :restrict_with_error
  has_many :purchase_orders, dependent: :restrict_with_error
  has_many :sales_orders, dependent: :restrict_with_error

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end

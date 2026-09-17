class SalesOrder < ApplicationRecord
  belongs_to :customer
  belongs_to :user
  has_many :sales_order_items, dependent: :destroy
  accepts_nested_attributes_for :sales_order_items, allow_destroy: true, reject_if: :all_blank

  enum :status, { draft: "draft", confirmed: "confirmed" }, default: "draft", validate: true

  validates :sales_order_items, presence: true
end

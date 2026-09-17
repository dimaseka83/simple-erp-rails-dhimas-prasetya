class PurchaseOrder < ApplicationRecord
  belongs_to :supplier
  belongs_to :user
  has_many :purchase_order_items, dependent: :destroy
  accepts_nested_attributes_for :purchase_order_items, allow_destroy: true, reject_if: :all_blank

  enum :status, { draft: "draft", ordered: "ordered", received: "received" }, default: "draft", validate: true

  validates :purchase_order_items, presence: true
end

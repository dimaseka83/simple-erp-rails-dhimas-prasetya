class PurchaseOrdersManager < ApplicationManager
  class << self
    def create(supplier_id:, user:, purchase_order_items_attributes:)
      purchase_order = PurchaseOrder.new(
        supplier_id: supplier_id, user: user, status: "draft",
        purchase_order_items_attributes: purchase_order_items_attributes
      )
      purchase_order.save ? success(purchase_order) : invalid(purchase_order)
    end

    def update(purchase_order:, supplier_id:, purchase_order_items_attributes:)
      return failure(I18n.t("purchase_orders.errors.not_draft")) unless purchase_order.draft?

      purchase_order.purchase_order_items.destroy_all
      purchase_order.assign_attributes(supplier_id: supplier_id, purchase_order_items_attributes: purchase_order_items_attributes)
      purchase_order.save ? success(purchase_order) : invalid(purchase_order)
    end

    def mark_as_ordered(purchase_order:)
      return failure(I18n.t("purchase_orders.errors.not_draft")) unless purchase_order.draft?

      purchase_order.update!(status: "ordered")
      success(purchase_order)
    end

    # Receiving a PO adds stock for every line item — the module
    # integration the roadmap calls out. Reuses StockMovementsManager
    # (already enforces valid quantities) instead of writing stock
    # directly, and rolls back the whole receipt if any line fails.
    def mark_as_received(purchase_order:, user:)
      return failure(I18n.t("purchase_orders.errors.not_ordered")) unless purchase_order.ordered?

      result = nil
      PurchaseOrder.transaction do
        purchase_order.purchase_order_items.includes(:product).each do |item|
          movement_result = ::StockMovementsManager.create(
            product: item.product, user: user, movement_type: "stock_in",
            quantity: item.quantity, note: "PO ##{purchase_order.id}"
          )
          if movement_result.failure?
            result = failure(movement_result.errors.first)
            raise ActiveRecord::Rollback
          end
        end
        purchase_order.update!(status: "received") unless result
      end
      result || success(purchase_order)
    end
  end
end

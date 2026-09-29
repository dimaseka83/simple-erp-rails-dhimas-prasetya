class PurchaseOrdersManager < ApplicationManager
  class << self
    def create(supplier_id:, user:, purchase_order_items_attributes:, new_supplier: nil)
      result = nil
      PurchaseOrder.transaction do
        supplier_id, result = resolve_supplier(supplier_id, new_supplier)
        raise ActiveRecord::Rollback if result

        purchase_order = PurchaseOrder.new(
          supplier_id: supplier_id, user: user, status: "draft",
          purchase_order_items_attributes: purchase_order_items_attributes
        )
        result = purchase_order.save ? success(purchase_order) : invalid(purchase_order)
      end
      result
    end

    def update(purchase_order:, supplier_id:, purchase_order_items_attributes:, new_supplier: nil)
      return failure(I18n.t("purchase_orders.errors.not_draft")) unless purchase_order.draft?

      result = nil
      PurchaseOrder.transaction do
        supplier_id, result = resolve_supplier(supplier_id, new_supplier)
        raise ActiveRecord::Rollback if result

        purchase_order.purchase_order_items.destroy_all
        purchase_order.assign_attributes(supplier_id: supplier_id, purchase_order_items_attributes: purchase_order_items_attributes)
        result = purchase_order.save ? success(purchase_order) : invalid(purchase_order)
      end
      result
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

    private
      # If new_supplier[:name] is present, create that supplier and use its
      # id instead of whatever was chosen in the dropdown — lets the PO
      # form's "+ Add new supplier" disclosure create both records in one
      # submit instead of sending the user to /suppliers and back. Returns
      # [supplier_id, nil] on success or [nil, failure_result] so the
      # caller can roll back the whole PO along with the failed supplier.
      def resolve_supplier(supplier_id, new_supplier)
        return [ supplier_id, nil ] if new_supplier.blank? || new_supplier[:name].blank?

        supplier_result = ::SuppliersManager.create(**new_supplier)
        return [ nil, supplier_result ] if supplier_result.failure?

        [ supplier_result.object.id, nil ]
      end
  end
end

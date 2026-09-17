class SalesOrdersManager < ApplicationManager
  class << self
    def create(customer_id:, user:, sales_order_items_attributes:)
      sales_order = SalesOrder.new(
        customer_id: customer_id, user: user, status: "draft",
        sales_order_items_attributes: sales_order_items_attributes
      )
      sales_order.save ? success(sales_order) : invalid(sales_order)
    end

    def update(sales_order:, customer_id:, sales_order_items_attributes:)
      return failure(I18n.t("sales_orders.errors.not_draft")) unless sales_order.draft?

      sales_order.sales_order_items.destroy_all
      sales_order.assign_attributes(customer_id: customer_id, sales_order_items_attributes: sales_order_items_attributes)
      sales_order.save ? success(sales_order) : invalid(sales_order)
    end

    # Confirming an SO removes stock for every line item — validated
    # against current stock (not just checked-then-hope: StockMovementsManager
    # rejects any line that would take stock negative), and the whole
    # confirmation rolls back if one line is short, so a sale never goes
    # through partially filled.
    def confirm(sales_order:, user:)
      return failure(I18n.t("sales_orders.errors.not_draft")) unless sales_order.draft?

      result = nil
      SalesOrder.transaction do
        sales_order.sales_order_items.includes(:product).each do |item|
          movement_result = ::StockMovementsManager.create(
            product: item.product, user: user, movement_type: "stock_out",
            quantity: item.quantity, note: "SO ##{sales_order.id}"
          )
          if movement_result.failure?
            result = failure(movement_result.errors.first)
            raise ActiveRecord::Rollback
          end
        end
        sales_order.update!(status: "confirmed") unless result
      end
      result || success(sales_order)
    end
  end
end

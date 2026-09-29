class SalesOrdersManager < ApplicationManager
  class << self
    def create(customer_id:, user:, sales_order_items_attributes:, new_customer: nil)
      result = nil
      SalesOrder.transaction do
        customer_id, result = resolve_customer(customer_id, new_customer)
        raise ActiveRecord::Rollback if result

        sales_order = SalesOrder.new(
          customer_id: customer_id, user: user, status: "draft",
          sales_order_items_attributes: sales_order_items_attributes
        )
        result = sales_order.save ? success(sales_order) : invalid(sales_order)
      end
      result
    end

    def update(sales_order:, customer_id:, sales_order_items_attributes:, new_customer: nil)
      return failure(I18n.t("sales_orders.errors.not_draft")) unless sales_order.draft?

      result = nil
      SalesOrder.transaction do
        customer_id, result = resolve_customer(customer_id, new_customer)
        raise ActiveRecord::Rollback if result

        sales_order.sales_order_items.destroy_all
        sales_order.assign_attributes(customer_id: customer_id, sales_order_items_attributes: sales_order_items_attributes)
        result = sales_order.save ? success(sales_order) : invalid(sales_order)
      end
      result
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

    private
      # Same idea as PurchaseOrdersManager#resolve_supplier: if
      # new_customer[:name] is present, create that customer and use its
      # id, so the SO form's "+ Add new customer" disclosure creates both
      # records in one submit.
      def resolve_customer(customer_id, new_customer)
        return [ customer_id, nil ] if new_customer.blank? || new_customer[:name].blank?

        customer_result = ::CustomersManager.create(**new_customer)
        return [ nil, customer_result ] if customer_result.failure?

        [ customer_result.object.id, nil ]
      end
  end
end

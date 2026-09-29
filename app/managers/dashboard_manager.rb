# Read-only, but the aggregation (monthly totals, ranking products by
# units sold) is business logic, not a query a controller index action
# should inline — so it gets a Manager like any other controller, even
# though nothing here writes to the database.
class DashboardManager < ApplicationManager
  MONTHS_BACK = 5
  TOP_PRODUCTS_LIMIT = 5

  class << self
    def overview
      success(
        OpenStruct.new(
          total_stock_quantity: total_stock_quantity,
          purchase_orders_this_month_count: purchase_orders_this_month_count,
          sales_orders_this_month_count: sales_orders_this_month_count,
          monthly_sales: monthly_sales,
          top_products: top_products
        )
      )
    end

    private
      def total_stock_quantity
        Product.sum(:stock_quantity)
      end

      def purchase_orders_this_month_count
        PurchaseOrder.where(created_at: Time.current.all_month).count
      end

      def sales_orders_this_month_count
        SalesOrder.where(created_at: Time.current.all_month).count
      end

      # Last MONTHS_BACK+1 calendar months (oldest first), each paired with
      # the revenue booked in it. Confirmed orders only — a draft SO isn't
      # a sale yet.
      def monthly_sales
        range_start = MONTHS_BACK.months.ago.beginning_of_month
        rows = SalesOrderItem.joins(:sales_order).merge(SalesOrder.confirmed)
          .where(sales_orders: { created_at: range_start.. })
          .pluck("sales_orders.created_at", :quantity, :unit_price)

        totals_by_month = rows.each_with_object(Hash.new(0)) do |(created_at, quantity, unit_price), totals|
          totals[created_at.beginning_of_month] += quantity * unit_price
        end

        MONTHS_BACK.downto(0).map do |months_ago|
          month = months_ago.months.ago.beginning_of_month
          { month: month, total: totals_by_month[month] || 0 }
        end
      end

      # Best-selling products by units sold, confirmed orders only.
      def top_products
        SalesOrderItem.joins(:sales_order, :product).merge(SalesOrder.confirmed)
          .group("products.name")
          .sum(:quantity)
          .sort_by { |_name, quantity| -quantity }
          .first(TOP_PRODUCTS_LIMIT)
          .map { |name, quantity| { name: name, quantity: quantity } }
      end
  end
end

class DashboardPresenter < ApplicationPresenter
  def initialize(view, user:, overview:)
    super(view)
    @user = user
    @overview = overview
  end

  def signed_in_as
    view.t("dashboard.index.signed_in_as", email: @user.email_address)
  end

  def total_stock_quantity_formatted
    view.number_with_delimiter(@overview.total_stock_quantity.to_i)
  end

  def purchase_orders_this_month_count
    @overview.purchase_orders_this_month_count
  end

  def sales_orders_this_month_count
    @overview.sales_orders_this_month_count
  end

  # ApexCharts-ready shape, also what gets pushed to `gon` — one method,
  # two consumers, per the "shared shape" rule for Vue/gon data.
  def monthly_sales_chart_data
    {
      categories: @overview.monthly_sales.map { |row| view.l(row[:month], format: "%b %Y") },
      series: @overview.monthly_sales.map { |row| row[:total].to_f }
    }
  end

  def top_products_chart_data
    {
      categories: @overview.top_products.map { |row| row[:name] },
      series: @overview.top_products.map { |row| row[:quantity].to_f }
    }
  end

  def top_products_empty?
    @overview.top_products.empty?
  end
end

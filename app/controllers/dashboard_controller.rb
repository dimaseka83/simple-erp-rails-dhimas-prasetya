class DashboardController < ApplicationController
  def index
    result = ::DashboardManager.overview
    @dashboard_presenter = DashboardPresenter.new(view_context, user: Current.user, overview: result.object)
    gon.monthly_sales_chart = @dashboard_presenter.monthly_sales_chart_data
    gon.top_products_chart = @dashboard_presenter.top_products_chart_data
    gon.currency_format = @dashboard_presenter.currency_format
  end
end

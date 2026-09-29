class SalesOrdersController < ApplicationController
  before_action :set_sales_order, only: %i[ show edit update confirm invoice ]
  protect_from_duplicate_requests only: %i[ create update confirm ]

  def index
    sales_orders = paginate(SalesOrder.includes(:customer, :sales_order_items).search(params[:q]).order(created_at: :desc))
    @sales_order_presenter = SalesOrderPresenter.new(view_context, sales_orders: sales_orders)
  end

  def show
    @sales_order_presenter = SalesOrderPresenter.new(view_context, sales_order: @sales_order)
  end

  def invoice
    @sales_order_presenter = SalesOrderPresenter.new(view_context, sales_order: @sales_order)
    render layout: "invoice"
  end

  def new
    @sales_order = SalesOrder.new
    @sales_order_presenter = form_presenter(@sales_order)
  end

  def create
    result = ::SalesOrdersManager.create(user: Current.user, **sales_order_params)
    if result.success?
      redirect_to sales_order_path(result.object), notice: t(".notice")
    else
      render_form_errors(result.object || SalesOrder.new)
    end
  end

  def edit
    @sales_order_presenter = form_presenter(@sales_order)
  end

  def update
    result = ::SalesOrdersManager.update(sales_order: @sales_order, **sales_order_params)
    if result.success?
      redirect_to sales_order_path(result.object), notice: t(".notice")
    else
      render_form_errors(result.object || @sales_order)
    end
  end

  def confirm
    result = ::SalesOrdersManager.confirm(sales_order: @sales_order, user: Current.user)
    redirect_to sales_order_path(@sales_order), notice: result.success? ? t(".notice") : nil, alert: result.failure? ? result.errors.first : nil
  end

  private
    def set_sales_order
      @sales_order = SalesOrder.find(params[:id])
    end

    def sales_order_params
      params.require(:sales_order)
            .permit(:customer_id,
              sales_order_items_attributes: %i[ product_id quantity unit_price ],
              new_customer: %i[ name contact ])
            .to_h.deep_symbolize_keys
    end

    def form_presenter(sales_order)
      presenter = SalesOrderPresenter.new(view_context, sales_order: sales_order, customers: Customer.order(:name), products: Product.order(:name))
      gon.products = presenter.product_options_for_vue
      gon.initial_items = presenter.initial_items_for_vue
      gon.currency_format = presenter.currency_format
      presenter
    end

    def render_form_errors(sales_order)
      @sales_order = sales_order
      @sales_order_presenter = form_presenter(sales_order)
      render sales_order.persisted? ? :edit : :new, status: :unprocessable_entity
    end
end

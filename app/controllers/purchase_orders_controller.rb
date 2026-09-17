class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: %i[ show edit update mark_as_ordered mark_as_received ]
  protect_from_duplicate_requests only: %i[ create update mark_as_ordered mark_as_received ]

  def index
    purchase_orders = paginate(PurchaseOrder.includes(:supplier, :purchase_order_items).order(created_at: :desc))
    @purchase_order_presenter = PurchaseOrderPresenter.new(view_context, purchase_orders: purchase_orders)
  end

  def show
    @purchase_order_presenter = PurchaseOrderPresenter.new(view_context, purchase_order: @purchase_order)
  end

  def new
    @purchase_order = PurchaseOrder.new
    @purchase_order_presenter = form_presenter(@purchase_order)
  end

  def create
    result = ::PurchaseOrdersManager.create(user: Current.user, **purchase_order_params)
    if result.success?
      redirect_to purchase_order_path(result.object), notice: t(".notice")
    else
      render_form_errors(result.object || PurchaseOrder.new)
    end
  end

  def edit
    @purchase_order_presenter = form_presenter(@purchase_order)
  end

  def update
    result = ::PurchaseOrdersManager.update(purchase_order: @purchase_order, **purchase_order_params)
    if result.success?
      redirect_to purchase_order_path(result.object), notice: t(".notice")
    else
      render_form_errors(result.object || @purchase_order)
    end
  end

  def mark_as_ordered
    result = ::PurchaseOrdersManager.mark_as_ordered(purchase_order: @purchase_order)
    redirect_to purchase_order_path(@purchase_order), notice: result.success? ? t(".notice") : nil, alert: result.failure? ? result.errors.first : nil
  end

  def mark_as_received
    result = ::PurchaseOrdersManager.mark_as_received(purchase_order: @purchase_order, user: Current.user)
    redirect_to purchase_order_path(@purchase_order), notice: result.success? ? t(".notice") : nil, alert: result.failure? ? result.errors.first : nil
  end

  private
    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end

    def purchase_order_params
      params.require(:purchase_order)
            .permit(:supplier_id, purchase_order_items_attributes: %i[ product_id quantity unit_cost ])
            .to_h.symbolize_keys
    end

    def form_presenter(purchase_order)
      presenter = PurchaseOrderPresenter.new(view_context, purchase_order: purchase_order, suppliers: Supplier.order(:name), products: Product.order(:name))
      gon.products = presenter.product_options_for_vue
      gon.initial_items = presenter.initial_items_for_vue
      presenter
    end

    def render_form_errors(purchase_order)
      @purchase_order = purchase_order
      @purchase_order_presenter = form_presenter(purchase_order)
      render purchase_order.persisted? ? :edit : :new, status: :unprocessable_entity
    end
end

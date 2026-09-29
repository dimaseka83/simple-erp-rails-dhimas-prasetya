class StockMovementsController < ApplicationController
  before_action :set_product, only: :create
  protect_from_duplicate_requests only: :create

  def index
    movements = StockMovement.includes(:product, :user).search(params[:q]).order(created_at: :desc)
    movements = paginate(movements)
    @stock_movement_presenter = StockMovementPresenter.new(view_context, movements: movements)
  end

  def create
    result = ::StockMovementsManager.create(
      product: @product, user: Current.user, movement_type: params[:movement_type],
      quantity: params[:quantity], note: params[:note]
    )
    if result.success?
      redirect_to product_path(@product), notice: t(".notice")
    else
      redirect_to product_path(@product), alert: result.errors.first
    end
  end

  private
    def set_product
      @product = Product.find(params[:product_id])
    end
end

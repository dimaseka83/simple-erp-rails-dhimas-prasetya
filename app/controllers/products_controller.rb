class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update ]
  protect_from_duplicate_requests only: %i[ create update ]

  def index
    products = Product.includes(:category).search(params[:q]).order(:name)
    products = paginate(products)
    @presenter_list = products.map { |product| ProductPresenter.new(view_context, product: product) }
  end

  def show
    @presenter = ProductPresenter.new(view_context, product: @product)
    movements = @product.stock_movements.includes(:user).order(created_at: :desc).limit(50)
    @movement_presenters = movements.map { |movement| StockMovementPresenter.new(view_context, movement: movement) }
  end

  def new
    @product = Product.new
    @categories = Category.order(:name)
  end

  def create
    result = ::ProductsManager.create(**product_params)
    if result.success?
      redirect_to products_path, notice: t(".notice")
    else
      @product = result.object
      @categories = Category.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.order(:name)
  end

  def update
    result = ::ProductsManager.update(product: @product, **product_params)
    if result.success?
      redirect_to products_path, notice: t(".notice")
    else
      @product = result.object
      @categories = Category.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.expect(product: [ :category_id, :name, :sku, :unit, :cost_price, :selling_price ]).to_h.symbolize_keys
    end
end

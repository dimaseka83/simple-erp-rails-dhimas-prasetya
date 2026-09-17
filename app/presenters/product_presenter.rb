class ProductPresenter < ApplicationPresenter
  LOW_STOCK_THRESHOLD = 10

  def initialize(view, product: nil, products: nil, categories: nil, movements: nil)
    super(view)
    @product = product
    @products = products
    @categories = categories
    @movements = movements
  end

  # -- single product (show/edit) --------------------------------------

  def name
    @product.name
  end

  def sku
    @product.sku
  end

  def category_name
    @product.category.name
  end

  def unit_label
    view.t("units.#{@product.unit}")
  end

  def cost_price_formatted
    format_currency(@product.cost_price)
  end

  def selling_price_formatted
    format_currency(@product.selling_price)
  end

  def stock_quantity_formatted
    view.number_with_delimiter(@product.stock_quantity.to_i)
  end

  # Stock level is shown as colored mono text, not a badge pill — the
  # color itself carries the status (out/low/ok), see design.md §5.
  def stock_text_classes
    if @product.stock_quantity <= 0
      "stock--danger"
    elsif @product.stock_quantity <= LOW_STOCK_THRESHOLD
      "stock--warn"
    else
      "stock--accent"
    end
  end

  def path
    view.product_path(@product)
  end

  def edit_path
    view.edit_product_path(@product)
  end

  # -- product list (index) ---------------------------------------------

  def rows
    @products.map { |product| self.class.new(view, product: product).row }
  end

  def products_empty?
    @products.empty?
  end

  # -- form <select> options ---------------------------------------------

  def category_options
    @categories.map { |category| [ category.name, category.id ] }
  end

  def unit_options
    Product.units.keys.map { |unit| [ view.t("units.#{unit}"), unit ] }
  end

  # -- movement quick-add form + history (show) --------------------------

  def movement_type_options
    StockMovement.movement_types.keys.map { |type| [ view.t("stock_movements.types.#{type}"), type ] }
  end

  def movement_rows
    @movements.map { |movement| StockMovementPresenter.new(view, movement: movement).row }
  end

  def movements_empty?
    @movements.empty?
  end

  protected
    def row
      {
        name: name, sku: sku, category_name: category_name, unit_label: unit_label,
        selling_price_formatted: selling_price_formatted, stock_quantity_formatted: stock_quantity_formatted,
        stock_text_classes: stock_text_classes, path: path, edit_path: edit_path
      }
    end

  private
    def format_currency(amount)
      view.number_to_currency(amount, unit: "Rp ", precision: 0, delimiter: ".", separator: ",")
    end
end

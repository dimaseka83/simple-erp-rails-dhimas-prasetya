class ProductPresenter < ApplicationPresenter
  LOW_STOCK_THRESHOLD = 10

  # Options for the product form's <select> tags — no product instance
  # needed, so these are class methods rather than throwaway instances.
  def self.category_options(categories)
    categories.map { |category| [ category.name, category.id ] }
  end

  def self.unit_options(view)
    Product.units.keys.map { |unit| [ view.t("units.#{unit}"), unit ] }
  end

  def initialize(view, product:)
    super(view)
    @product = product
  end

  def id
    @product.id
  end

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
      "stock-danger"
    elsif @product.stock_quantity <= LOW_STOCK_THRESHOLD
      "stock-warn"
    else
      "stock-accent"
    end
  end

  def path
    view.product_path(@product)
  end

  def edit_path
    view.edit_product_path(@product)
  end

  private
    def format_currency(amount)
      view.number_to_currency(amount, unit: "Rp ", precision: 0, delimiter: ".", separator: ",")
    end
end

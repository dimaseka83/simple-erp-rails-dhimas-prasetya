class ProductPresenter < ApplicationPresenter
  LOW_STOCK_THRESHOLD = 10

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

  def low_stock?
    @product.stock_quantity <= LOW_STOCK_THRESHOLD
  end

  def stock_badge_classes
    low_stock? ? "badge-low-stock" : "badge-ok-stock"
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

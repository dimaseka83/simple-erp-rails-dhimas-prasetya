class ProductsManager < ApplicationManager
  class << self
    def create(category_id:, name:, sku:, unit:, cost_price:, selling_price:)
      product = Product.new(
        category_id: category_id, name: name, sku: sku, unit: unit,
        cost_price: cost_price, selling_price: selling_price
      )
      product.save ? success(product) : invalid(product)
    end

    def update(product:, category_id:, name:, sku:, unit:, cost_price:, selling_price:)
      product.update(
        category_id: category_id, name: name, sku: sku, unit: unit,
        cost_price: cost_price, selling_price: selling_price
      ) ? success(product) : invalid(product)
    end
  end
end

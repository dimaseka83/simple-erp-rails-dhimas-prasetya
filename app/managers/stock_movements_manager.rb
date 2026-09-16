class StockMovementsManager < ApplicationManager
  class << self
    def create(product:, user:, movement_type:, quantity:, note:)
      quantity = quantity.to_d
      return failure(I18n.t("stock_movements.errors.invalid_quantity")) if quantity <= 0

      delta = movement_type == "stock_out" ? -quantity : quantity
      new_stock = product.stock_quantity + delta
      return failure(I18n.t("stock_movements.errors.insufficient_stock")) if new_stock.negative?

      movement = nil
      Product.transaction do
        movement = product.stock_movements.create!(user: user, movement_type: movement_type, quantity: quantity, note: note)
        product.update!(stock_quantity: new_stock)
      end
      success(movement)
    rescue ActiveRecord::RecordInvalid => e
      failure(*e.record.errors.full_messages)
    end
  end
end

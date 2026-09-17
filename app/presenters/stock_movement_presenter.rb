class StockMovementPresenter < ApplicationPresenter
  def initialize(view, movement: nil, movements: nil)
    super(view)
    @movement = movement
    @movements = movements
  end

  def product_name
    @movement.product.name
  end

  def type_label
    view.t("stock_movements.types.#{@movement.movement_type}")
  end

  def type_badge_classes
    @movement.stock_in? ? "badge-accent" : "badge-neutral"
  end

  def quantity_formatted
    sign = @movement.stock_in? ? "+" : "-"
    "#{sign}#{view.number_with_delimiter(@movement.quantity.to_i)}"
  end

  def note
    @movement.note
  end

  def user_email
    @movement.user.email_address
  end

  def occurred_at
    @movement.created_at.strftime("%d %b %Y %H:%M")
  end

  def rows
    @movements.map { |movement| self.class.new(view, movement: movement).row }
  end

  def movements_empty?
    @movements.empty?
  end

  # Public so ProductPresenter can compose it for the show page's
  # movement history — still never called directly from .haml.
  def row
    {
      product_name: product_name, type_label: type_label, type_badge_classes: type_badge_classes,
      quantity_formatted: quantity_formatted, note: note, user_email: user_email, occurred_at: occurred_at
    }
  end
end

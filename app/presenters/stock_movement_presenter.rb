class StockMovementPresenter < ApplicationPresenter
  # For the "record movement" <select> — no movement instance yet, so this
  # is a class method rather than needing a throwaway StockMovement.new.
  def self.type_options(view)
    StockMovement.movement_types.keys.map { |type| [ view.t("stock_movements.types.#{type}"), type ] }
  end

  def initialize(view, movement:)
    super(view)
    @movement = movement
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
end

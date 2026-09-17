class PurchaseOrderPresenter < ApplicationPresenter
  STATUS_BADGE_CLASSES = { "draft" => "badge--neutral", "ordered" => "badge--warn", "received" => "badge--accent" }.freeze

  def initialize(view, purchase_order: nil, purchase_orders: nil, suppliers: nil, products: nil)
    super(view)
    @purchase_order = purchase_order
    @purchase_orders = purchase_orders
    @suppliers = suppliers
    @products = products
  end

  # -- single purchase order (show/edit) ---------------------------------

  def id
    @purchase_order.id
  end

  def supplier_name
    @purchase_order.supplier.name
  end

  def status_label
    view.t("purchase_orders.status.#{@purchase_order.status}")
  end

  def status_badge_classes
    STATUS_BADGE_CLASSES.fetch(@purchase_order.status)
  end

  def date_formatted
    @purchase_order.created_at.strftime("%d %b %Y")
  end

  def total_formatted
    format_currency(@purchase_order.purchase_order_items.sum { |item| item.quantity * item.unit_cost })
  end

  def item_rows
    @purchase_order.purchase_order_items.map do |item|
      {
        product_name: item.product.name,
        quantity: view.number_with_delimiter(item.quantity.to_i),
        unit_cost_formatted: format_currency(item.unit_cost),
        subtotal_formatted: format_currency(item.quantity * item.unit_cost)
      }
    end
  end

  def path
    view.purchase_order_path(@purchase_order)
  end

  def edit_path
    view.edit_purchase_order_path(@purchase_order)
  end

  def draft?
    @purchase_order.draft?
  end

  def ordered?
    @purchase_order.ordered?
  end

  # -- form ---------------------------------------------------------------

  def form_url
    @purchase_order.persisted? ? view.purchase_order_path(@purchase_order) : view.purchase_orders_path
  end

  def form_heading
    @purchase_order.persisted? ? view.t("purchase_orders.edit.heading") : view.t("purchase_orders.new.heading")
  end

  def supplier_options
    @suppliers.map { |supplier| [ supplier.name, supplier.id ] }
  end

  def selected_supplier_id
    @purchase_order.supplier_id
  end

  # Pushed to `gon` by the controller (see CLAUDE.md "Form Kompleks dengan
  # Vue.js") so PurchaseOrderForm.vue reads window.gon.products instead of
  # a duplicated AJAX call — same shape the plain HAML select would use.
  def product_options_for_vue
    @products.map { |product| { id: product.id, name: product.name, defaultPrice: product.cost_price.to_f } }
  end

  def initial_items_for_vue
    @purchase_order.purchase_order_items.map do |item|
      { productId: item.product_id, quantity: item.quantity.to_f, unitCost: item.unit_cost.to_f }
    end
  end

  def item_form_labels_json
    {
      priceLabel: view.t("purchase_orders.show.unit_cost"),
      addItemLabel: view.t("purchase_orders.form.add_item"),
      removeItemLabel: view.t("purchase_orders.form.remove_item")
    }.to_json
  end

  # -- purchase order list (index) -----------------------------------------

  def rows
    @purchase_orders.map { |purchase_order| self.class.new(view, purchase_order: purchase_order).row }
  end

  def purchase_orders_empty?
    @purchase_orders.empty?
  end

  protected
    def row
      { id: id, supplier_name: supplier_name, status_label: status_label, status_badge_classes: status_badge_classes,
        total_formatted: total_formatted, date_formatted: date_formatted, path: path }
    end

  private
    def format_currency(amount)
      view.number_to_currency(amount, unit: "Rp ", precision: 0, delimiter: ".", separator: ",")
    end
end

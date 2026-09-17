class SalesOrderPresenter < ApplicationPresenter
  STATUS_BADGE_CLASSES = { "draft" => "badge--neutral", "confirmed" => "badge--accent" }.freeze

  def initialize(view, sales_order: nil, sales_orders: nil, customers: nil, products: nil)
    super(view)
    @sales_order = sales_order
    @sales_orders = sales_orders
    @customers = customers
    @products = products
  end

  # -- single sales order (show/edit/invoice) ------------------------------

  def id
    @sales_order.id
  end

  def customer_name
    @sales_order.customer.name
  end

  def status_label
    view.t("sales_orders.status.#{@sales_order.status}")
  end

  def status_badge_classes
    STATUS_BADGE_CLASSES.fetch(@sales_order.status)
  end

  def date_formatted
    @sales_order.created_at.strftime("%d %b %Y")
  end

  def total_formatted
    format_currency(total)
  end

  def item_rows
    @sales_order.sales_order_items.map do |item|
      {
        product_name: item.product.name,
        quantity: view.number_with_delimiter(item.quantity.to_i),
        unit_price_formatted: format_currency(item.unit_price),
        subtotal_formatted: format_currency(item.quantity * item.unit_price)
      }
    end
  end

  def path
    view.sales_order_path(@sales_order)
  end

  def edit_path
    view.edit_sales_order_path(@sales_order)
  end

  def invoice_path
    view.invoice_sales_order_path(@sales_order)
  end

  def draft?
    @sales_order.draft?
  end

  # -- form -----------------------------------------------------------------

  def form_url
    @sales_order.persisted? ? view.sales_order_path(@sales_order) : view.sales_orders_path
  end

  def form_heading
    @sales_order.persisted? ? view.t("sales_orders.edit.heading") : view.t("sales_orders.new.heading")
  end

  def customer_options
    @customers.map { |customer| [ customer.name, customer.id ] }
  end

  def selected_customer_id
    @sales_order.customer_id
  end

  # Pushed to `gon` by the controller (see CLAUDE.md "Form Kompleks dengan
  # Vue.js") so SalesOrderForm.vue reads window.gon.products instead of a
  # duplicated AJAX call — same shape the plain HAML select would use.
  def product_options_for_vue
    @products.map { |product| { id: product.id, name: product.name, defaultPrice: product.selling_price.to_f } }
  end

  def initial_items_for_vue
    @sales_order.sales_order_items.map do |item|
      { productId: item.product_id, quantity: item.quantity.to_f, unitPrice: item.unit_price.to_f }
    end
  end

  def item_form_labels_json
    {
      priceLabel: view.t("sales_orders.show.unit_price"),
      addItemLabel: view.t("sales_orders.form.add_item"),
      removeItemLabel: view.t("sales_orders.form.remove_item")
    }.to_json
  end

  # -- sales order list (index) ----------------------------------------------

  def rows
    @sales_orders.map { |sales_order| self.class.new(view, sales_order: sales_order).row }
  end

  def sales_orders_empty?
    @sales_orders.empty?
  end

  protected
    def row
      { id: id, customer_name: customer_name, status_label: status_label, status_badge_classes: status_badge_classes,
        total_formatted: total_formatted, date_formatted: date_formatted, path: path }
    end

  private
    def total
      @sales_order.sales_order_items.sum { |item| item.quantity * item.unit_price }
    end

    def format_currency(amount)
      view.number_to_currency(amount, unit: "Rp ", precision: 0, delimiter: ".", separator: ",")
    end
end

# Chrome shared by every page (sidebar nav, locale switcher, signed-in
# user) — not tied to any one controller's resource, so it gets its own
# single instance variable (@layout_presenter) separate from each
# controller action's own @presenter.
class LayoutPresenter < ApplicationPresenter
  LOCALES = %w[en id].freeze

  def initialize(view, current_user:)
    super(view)
    @current_user = current_user
  end

  def nav_dashboard_link_classes
    link_classes(view.root_path)
  end

  def nav_products_link_classes
    link_classes(view.products_path)
  end

  def nav_stock_movements_link_classes
    link_classes(view.stock_movements_path)
  end

  def nav_suppliers_link_classes
    link_classes(view.suppliers_path)
  end

  def nav_purchase_orders_link_classes
    link_classes(view.purchase_orders_path)
  end

  def nav_customers_link_classes
    link_classes(view.customers_path)
  end

  def nav_sales_orders_link_classes
    link_classes(view.sales_orders_path)
  end

  def locale_links
    LOCALES.map do |locale|
      {
        label: locale.upcase,
        url: view.set_locale_path(locale: locale),
        css_class: locale == I18n.locale.to_s ? "locale-link--active" : "locale-link--inactive"
      }
    end
  end

  def current_user_initials
    @current_user&.email_address&.first&.upcase
  end

  def current_user_email
    @current_user&.email_address
  end

  private
    def link_classes(path)
      view.current_page?(path) ? "nav-link--active" : "nav-link--inactive"
    end
end

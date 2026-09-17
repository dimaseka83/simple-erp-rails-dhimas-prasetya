class CustomerPresenter < ApplicationPresenter
  def initialize(view, customer:)
    super(view)
    @customer = customer
  end

  def form_url
    @customer.persisted? ? view.customer_path(@customer) : view.customers_path
  end

  def form_heading
    @customer.persisted? ? view.t("customers.index.edit_heading") : view.t("customers.index.new_heading")
  end
end

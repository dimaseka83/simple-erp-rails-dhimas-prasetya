class SupplierPresenter < ApplicationPresenter
  def initialize(view, supplier:)
    super(view)
    @supplier = supplier
  end

  def form_url
    @supplier.persisted? ? view.supplier_path(@supplier) : view.suppliers_path
  end

  def form_heading
    @supplier.persisted? ? view.t("suppliers.index.edit_heading") : view.t("suppliers.index.new_heading")
  end
end

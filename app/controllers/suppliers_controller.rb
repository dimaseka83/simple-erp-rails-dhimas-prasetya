class SuppliersController < ApplicationController
  protect_from_duplicate_requests only: %i[ create update ]

  def index
    @suppliers = Supplier.order(:name)
    @supplier = params[:edit].present? ? Supplier.find(params[:edit]) : Supplier.new
    @supplier_presenter = SupplierPresenter.new(view_context, supplier: @supplier)
    @show_form = params[:new].present? || params[:edit].present?
  end

  def create
    result = ::SuppliersManager.create(**supplier_params)
    if result.success?
      redirect_to suppliers_path, notice: t(".notice")
    else
      render_form_errors(result.object)
    end
  end

  def update
    supplier = Supplier.find(params[:id])
    result = ::SuppliersManager.update(supplier: supplier, **supplier_params)
    if result.success?
      redirect_to suppliers_path, notice: t(".notice")
    else
      render_form_errors(result.object)
    end
  end

  private
    def supplier_params
      params.expect(supplier: [ :name, :contact, :address ]).to_h.symbolize_keys
    end

    def render_form_errors(supplier)
      @suppliers = Supplier.order(:name)
      @supplier = supplier
      @supplier_presenter = SupplierPresenter.new(view_context, supplier: supplier)
      @show_form = true
      render :index, status: :unprocessable_entity
    end
end

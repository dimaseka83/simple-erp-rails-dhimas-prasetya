class CustomersController < ApplicationController
  protect_from_duplicate_requests only: %i[ create update ]

  def index
    @customers = Customer.order(:name)
    @customer = params[:edit].present? ? Customer.find(params[:edit]) : Customer.new
    @customer_presenter = CustomerPresenter.new(view_context, customer: @customer)
    @show_form = params[:new].present? || params[:edit].present?
  end

  def create
    result = ::CustomersManager.create(**customer_params)
    if result.success?
      redirect_to customers_path, notice: t(".notice")
    else
      render_form_errors(result.object)
    end
  end

  def update
    customer = Customer.find(params[:id])
    result = ::CustomersManager.update(customer: customer, **customer_params)
    if result.success?
      redirect_to customers_path, notice: t(".notice")
    else
      render_form_errors(result.object)
    end
  end

  private
    def customer_params
      params.expect(customer: [ :name, :contact ]).to_h.symbolize_keys
    end

    def render_form_errors(customer)
      @customers = Customer.order(:name)
      @customer = customer
      @customer_presenter = CustomerPresenter.new(view_context, customer: customer)
      @show_form = true
      render :index, status: :unprocessable_entity
    end
end

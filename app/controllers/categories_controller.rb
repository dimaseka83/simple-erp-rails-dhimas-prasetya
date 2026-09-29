class CategoriesController < ApplicationController
  protect_from_duplicate_requests only: %i[ create update ]

  def index
    @categories = Category.search(params[:q]).order(:name)
    @category = params[:edit].present? ? Category.find(params[:edit]) : Category.new
    @category_presenter = CategoryPresenter.new(view_context, category: @category)
    @show_form = params[:new].present? || params[:edit].present?
  end

  def create
    result = ::CategoriesManager.create(name: category_params[:name])
    if result.success?
      redirect_to categories_path, notice: t(".notice")
    else
      render_form_errors(result.object)
    end
  end

  def update
    category = Category.find(params[:id])
    result = ::CategoriesManager.update(category: category, name: category_params[:name])
    if result.success?
      redirect_to categories_path, notice: t(".notice")
    else
      render_form_errors(result.object)
    end
  end

  private
    def category_params
      params.expect(category: [ :name ])
    end

    def render_form_errors(category)
      @categories = Category.order(:name)
      @category = category
      @category_presenter = CategoryPresenter.new(view_context, category: category)
      @show_form = true
      render :index, status: :unprocessable_entity
    end
end

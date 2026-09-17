class CategoryPresenter < ApplicationPresenter
  def initialize(view, category:)
    super(view)
    @category = category
  end

  def form_url
    @category.persisted? ? view.category_path(@category) : view.categories_path
  end

  def form_heading
    @category.persisted? ? view.t("categories.index.edit_heading") : view.t("categories.index.new_heading")
  end
end

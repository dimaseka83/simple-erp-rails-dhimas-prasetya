class CategoriesManager < ApplicationManager
  class << self
    def create(name:)
      category = Category.new(name: name)
      category.save ? success(category) : invalid(category)
    end

    def update(category:, name:)
      category.update(name: name) ? success(category) : invalid(category)
    end
  end
end

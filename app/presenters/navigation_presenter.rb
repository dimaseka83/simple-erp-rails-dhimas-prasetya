class NavigationPresenter < ApplicationPresenter
  def link_classes(path)
    view.current_page?(path) ? "nav-link-active" : "nav-link-inactive"
  end

  def soon_item_classes
    "nav-link-soon"
  end

  def soon_badge_classes
    "nav-badge"
  end
end

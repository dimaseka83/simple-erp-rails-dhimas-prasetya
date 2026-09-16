class NavigationPresenter < ApplicationPresenter
  def dashboard_link_classes
    dashboard_active? ? "nav-link-active" : "nav-link-inactive"
  end

  def soon_item_classes
    "nav-link-soon"
  end

  def soon_badge_classes
    "nav-badge"
  end

  private
    def dashboard_active?
      view.current_page?(view.root_path)
    end
end

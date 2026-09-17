class ApplicationController < ActionController::Base
  include Authentication
  include RequestUuidProtection
  include Paginatable
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout "dashboard"

  around_action :use_locale
  before_action :set_layout_presenter

  helper_method :gon

  private
    def use_locale(&action)
      locale = cookies[:locale]&.to_sym
      locale = I18n.default_locale unless I18n.available_locales.include?(locale)
      I18n.with_locale(locale, &action)
    end

    # Rendered by every page (layouts/_sidebar, _topbar, _toolbar_controls)
    # regardless of which resource controller is acting — set once here so
    # those partials only ever read @layout_presenter, never instantiate
    # a presenter themselves.
    def set_layout_presenter
      @layout_presenter = LayoutPresenter.new(view_context, current_user: Current.user)
    end
end

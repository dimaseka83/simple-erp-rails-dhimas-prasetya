class ApplicationController < ActionController::Base
  include Authentication
  include RequestUuidProtection
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout "dashboard"

  around_action :use_locale

  helper_method :gon

  private
    def use_locale(&action)
      locale = cookies[:locale]&.to_sym
      locale = I18n.default_locale unless I18n.available_locales.include?(locale)
      I18n.with_locale(locale, &action)
    end
end

class ToolbarPresenter < ApplicationPresenter
  LOCALES = %w[en id].freeze

  def locales
    LOCALES
  end

  def locale_link_classes(locale)
    active_locale?(locale) ? "locale-link-active" : "locale-link-inactive"
  end

  private
    def active_locale?(locale)
      locale == I18n.locale.to_s
    end
end

class Locales::Switch < ApplicationManager
  def initialize(locale:)
    @locale = locale
  end

  def call
    return failure unless I18n.available_locales.map(&:to_s).include?(@locale)

    success(@locale)
  end
end

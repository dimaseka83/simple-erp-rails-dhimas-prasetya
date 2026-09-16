class LocalesManager < ApplicationManager
  class << self
    def switch(locale:)
      return failure unless I18n.available_locales.map(&:to_s).include?(locale)

      success(locale)
    end
  end
end

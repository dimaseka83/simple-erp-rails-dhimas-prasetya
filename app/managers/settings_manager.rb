class SettingsManager < ApplicationManager
  class << self
    def update(currency:)
      setting = Setting.current
      setting.update(currency: currency) ? success(setting) : invalid(setting)
    end
  end
end

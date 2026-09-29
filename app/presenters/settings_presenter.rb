class SettingsPresenter < ApplicationPresenter
  def initialize(view, setting:)
    super(view)
    @setting = setting
  end

  def currency_options
    Setting.currencies.keys.map { |currency| [ currency_option_label(currency), currency ] }
  end

  def selected_currency
    @setting.currency
  end

  private
    def currency_option_label(currency)
      symbol = Setting::CURRENCY_FORMATS.fetch(currency)[:symbol]
      "#{view.t("settings.currencies.#{currency}")} (#{symbol})"
    end
end

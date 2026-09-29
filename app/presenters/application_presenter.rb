# Presenters hold view logic too complex for a template: branching on
# state to pick CSS classes, formatting, anything beyond "call a helper".
# Haml should read top to bottom with no inline Ruby conditionals.
class ApplicationPresenter
  def initialize(view)
    @view = view
  end

  # Symbol/precision/separators for the app-wide currency (see Setting) —
  # public so controllers can push the same shape to `gon` for the Vue
  # order forms, instead of duplicating the lookup there.
  def currency_format
    @currency_format ||= Setting.current.currency_format
  end

  def currency_symbol
    currency_format[:symbol]
  end

  private
    attr_reader :view

    # One formatter shared by every presenter, so switching currency in
    # Settings changes every money value at once instead of each presenter
    # picking its own symbol. A trailing space in `unit:` keeps symbol and
    # number visually separated ("Rp 15.000", not "Rp15.000") for every
    # currency, not just IDR.
    def format_as_currency(amount)
      format = currency_format
      view.number_to_currency(
        amount, unit: "#{format[:symbol]} ",
        precision: format[:precision], delimiter: format[:delimiter], separator: format[:separator]
      )
    end
end

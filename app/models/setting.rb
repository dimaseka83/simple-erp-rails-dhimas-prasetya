# Single-row app-wide configuration (currency for now). Formatting rules
# per currency (symbol, decimal precision, separators) are just data about
# each currency, not business logic, so they live here as a constant next
# to the enum they key off — presenters read it, they don't own it.
class Setting < ApplicationRecord
  CURRENCY_FORMATS = {
    "idr" => { symbol: "Rp", precision: 0, delimiter: ".", separator: "," },
    "usd" => { symbol: "$", precision: 2, delimiter: ",", separator: "." },
    "eur" => { symbol: "€", precision: 2, delimiter: ".", separator: "," }
  }.freeze

  enum :currency, { idr: "idr", usd: "usd", eur: "eur" }, default: "idr", validate: true

  after_commit :clear_cache

  def self.current
    @current ||= first_or_create!
  end

  def currency_format
    CURRENCY_FORMATS.fetch(currency)
  end

  private
    def clear_cache
      self.class.remove_instance_variable(:@current) if self.class.instance_variable_defined?(:@current)
    end
end

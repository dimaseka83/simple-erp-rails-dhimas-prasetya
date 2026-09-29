// Mirrors ApplicationPresenter#format_as_currency in JS for the Vue order
// forms, reading the same { symbol, precision, delimiter, separator } shape
// pushed to `gon` by the controller — one source of truth (Setting), two
// renderers (Ruby for show pages, this for the live Vue total/subtotal).
export function formatCurrency(amount) {
  const format = window.gon?.currency_format ?? { symbol: "Rp", precision: 0, delimiter: ".", separator: "," }
  const fixed = (Number(amount) || 0).toFixed(format.precision)
  const [whole, decimals] = fixed.split(".")
  const wholeWithThousands = whole.replace(/\B(?=(\d{3})+(?!\d))/g, format.delimiter)
  const decimalPart = format.precision > 0 ? `${format.separator}${decimals}` : ""
  return `${format.symbol} ${wholeWithThousands}${decimalPart}`
}

admin = User.find_or_create_by!(email_address: "admin@simple-erp.test") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
end

[ "General", "Raw Materials", "Finished Goods" ].each do |name|
  Category.find_or_create_by!(name: name)
end

supplier = Supplier.find_or_create_by!(name: "PT Sumber Makmur") do |s|
  s.contact = "021-5551234"
  s.address = "Jl. Industri Raya No. 10, Jakarta"
end

customer = Customer.find_or_create_by!(name: "Toko Jaya Abadi") do |c|
  c.contact = "081234567890"
end

products_seed = [
  { name: "Beras Premium 5kg", sku: "BRS-5KG", category: "Finished Goods", unit: "pcs", cost_price: 55_000, selling_price: 68_000 },
  { name: "Minyak Goreng 2L", sku: "MYK-2L", category: "Finished Goods", unit: "pcs", cost_price: 32_000, selling_price: 39_000 },
  { name: "Gula Pasir 1kg", sku: "GLA-1KG", category: "Finished Goods", unit: "kg", cost_price: 13_000, selling_price: 16_000 },
  { name: "Tepung Terigu 1kg", sku: "TPG-1KG", category: "Raw Materials", unit: "kg", cost_price: 9_500, selling_price: 12_000 },
  { name: "Kardus Packing", sku: "KRD-BOX", category: "General", unit: "box", cost_price: 3_000, selling_price: 4_500 }
]

products = products_seed.map do |attrs|
  category = Category.find_by!(name: attrs[:category])
  Product.find_or_create_by!(sku: attrs[:sku]) do |product|
    product.name = attrs[:name]
    product.category = category
    product.unit = attrs[:unit]
    product.cost_price = attrs[:cost_price]
    product.selling_price = attrs[:selling_price]
  end
end

# Demo activity (stock-in + a spread of confirmed sales across the last few
# months) so the dashboard charts have something to show. Guarded by
# PurchaseOrder/SalesOrder.none? so re-running db:seed doesn't pile up more.
if PurchaseOrder.none?
  stock_in = PurchaseOrdersManager.create(
    supplier_id: supplier.id, user: admin,
    purchase_order_items_attributes: products.map { |product| { product_id: product.id, quantity: 500, unit_cost: product.cost_price } }
  )
  PurchaseOrdersManager.mark_as_ordered(purchase_order: stock_in.object)
  PurchaseOrdersManager.mark_as_received(purchase_order: stock_in.object, user: admin)
end

if SalesOrder.none?
  5.downto(0) do |months_ago|
    rand(2..3).times do
      order_date = months_ago.months.ago.beginning_of_month + rand(0..27).days
      items = products.sample(rand(1..2)).map do |product|
        { product_id: product.id, quantity: rand(3..12), unit_price: product.selling_price }
      end

      result = SalesOrdersManager.create(customer_id: customer.id, user: admin, sales_order_items_attributes: items)
      SalesOrdersManager.confirm(sales_order: result.object, user: admin)
      result.object.update_column(:created_at, order_date)
    end
  end
end

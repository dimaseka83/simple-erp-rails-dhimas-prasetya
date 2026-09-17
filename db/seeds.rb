User.find_or_create_by!(email_address: "admin@simple-erp.test") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
end

["General", "Raw Materials", "Finished Goods"].each do |name|
  Category.find_or_create_by!(name: name)
end

Supplier.find_or_create_by!(name: "PT Sumber Makmur") do |supplier|
  supplier.contact = "021-5551234"
  supplier.address = "Jl. Industri Raya No. 10, Jakarta"
end

Customer.find_or_create_by!(name: "Toko Jaya Abadi") do |customer|
  customer.contact = "081234567890"
end

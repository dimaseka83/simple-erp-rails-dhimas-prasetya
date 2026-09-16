User.find_or_create_by!(email_address: "admin@simple-erp.test") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
end

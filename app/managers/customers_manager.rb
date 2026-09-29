class CustomersManager < ApplicationManager
  class << self
    def create(name:, contact: nil)
      customer = Customer.new(name: name, contact: contact)
      customer.save ? success(customer) : invalid(customer)
    end

    def update(customer:, name:, contact:)
      customer.update(name: name, contact: contact) ? success(customer) : invalid(customer)
    end
  end
end

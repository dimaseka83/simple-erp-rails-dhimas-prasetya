class SuppliersManager < ApplicationManager
  class << self
    def create(name:, contact:, address:)
      supplier = Supplier.new(name: name, contact: contact, address: address)
      supplier.save ? success(supplier) : invalid(supplier)
    end

    def update(supplier:, name:, contact:, address:)
      supplier.update(name: name, contact: contact, address: address) ? success(supplier) : invalid(supplier)
    end
  end
end

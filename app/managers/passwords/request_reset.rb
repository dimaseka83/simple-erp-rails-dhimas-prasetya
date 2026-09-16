class Passwords::RequestReset < ApplicationManager
  def initialize(email_address:)
    @email_address = email_address
  end

  def call
    user = User.find_by(email_address: @email_address)
    PasswordsMailer.reset(user).deliver_later if user
    # Always succeeds: we don't reveal whether the address is registered.
    success
  end
end

class PasswordsManager < ApplicationManager
  class << self
    def request_reset(email_address:)
      user = User.find_by(email_address: email_address)
      PasswordsMailer.reset(user).deliver_later if user
      # Always succeeds: we don't reveal whether the address is registered.
      success
    end

    def reset(user:, password:, password_confirmation:)
      if user.update(password: password, password_confirmation: password_confirmation)
        user.sessions.destroy_all
        success(user)
      else
        failure(I18n.t("passwords.update.mismatch"))
      end
    end
  end
end

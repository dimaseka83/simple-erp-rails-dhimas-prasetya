class SessionsManager < ApplicationManager
  class << self
    def create(email_address:, password:, user_agent:, ip_address:)
      user = User.authenticate_by(email_address: email_address, password: password)
      return failure(I18n.t("sessions.create.invalid_credentials")) unless user

      session = user.sessions.create!(user_agent: user_agent, ip_address: ip_address)
      success(session)
    end
  end
end

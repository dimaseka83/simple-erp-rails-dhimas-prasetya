class Passwords::Reset < ApplicationManager
  def initialize(user:, password:, password_confirmation:)
    @user = user
    @password = password
    @password_confirmation = password_confirmation
  end

  def call
    if @user.update(password: @password, password_confirmation: @password_confirmation)
      @user.sessions.destroy_all
      success(@user)
    else
      failure(I18n.t("passwords.update.mismatch"))
    end
  end
end

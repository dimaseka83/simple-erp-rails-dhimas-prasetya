class PasswordsController < ApplicationController
  layout "application"

  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  protect_from_duplicate_requests only: %i[ create update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: t("passwords.create.rate_limited") }

  def new
  end

  def create
    ::Passwords::RequestReset.call(email_address: params[:email_address])
    redirect_to new_session_path, notice: t("passwords.create.notice")
  end

  def edit
  end

  def update
    result = ::Passwords::Reset.call(
      user: @user,
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )

    if result.success?
      redirect_to new_session_path, notice: t("passwords.update.notice")
    else
      redirect_to edit_password_path(params[:token]), alert: result.errors.first
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: t("passwords.invalid_token")
    end
end

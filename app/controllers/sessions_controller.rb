class SessionsController < ApplicationController
  layout "application"

  allow_unauthenticated_access only: %i[ new create ]
  protect_from_duplicate_requests only: :create
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: t("sessions.create.rate_limited") }

  def new
  end

  def create
    result = ::Sessions::Create.call(
      email_address: params[:email_address],
      password: params[:password],
      user_agent: request.user_agent,
      ip_address: request.remote_ip
    )

    if result.success?
      start_new_session_for(result.object)
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: result.errors.first
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end

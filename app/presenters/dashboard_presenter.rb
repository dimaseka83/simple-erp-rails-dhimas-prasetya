class DashboardPresenter < ApplicationPresenter
  def initialize(view, user:)
    super(view)
    @user = user
  end

  def signed_in_as
    view.t("dashboard.index.signed_in_as", email: @user.email_address)
  end
end

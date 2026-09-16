# Wraps Current.user for chrome shared across every authenticated page
# (the topbar), where there's no single controller action to hand a
# presenter down from — Current is itself already globally resolved.
class CurrentUserPresenter < ApplicationPresenter
  def initialize(view, user:)
    super(view)
    @user = user
  end

  def initials
    @user.email_address.first.upcase
  end

  def email_address
    @user.email_address
  end
end

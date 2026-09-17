class DashboardController < ApplicationController
  # No Manager here: Current.user is already resolved by the Authentication
  # concern before this action runs, so there's no query or business logic
  # left for a manager to own.
  def index
    @presenter = DashboardPresenter.new(view_context, user: Current.user)
  end
end

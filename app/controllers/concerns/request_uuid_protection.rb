# Forms carry a hidden `request_uuid` (see application_helper#request_uuid_field).
# The first request to claim a given uuid wins; retries from a double-click
# or a network retry redirect harmlessly instead of double-processing.
#
# Rails.cache.write(..., unless_exist: true) is atomic at the cache-store
# level, so two concurrent requests for the same uuid can't both "win" —
# that's what actually closes the race, not the presence of the uuid itself.
module RequestUuidProtection
  extend ActiveSupport::Concern

  class_methods do
    def protect_from_duplicate_requests(**options)
      before_action(**options) { reject_duplicate_request! }
    end
  end

  private
    def reject_duplicate_request!
      uuid = params[:request_uuid].presence
      return if uuid.nil?

      claimed = Rails.cache.write("request_uuid:#{uuid}", true, unless_exist: true, expires_in: 5.minutes)
      redirect_to(request.referer || root_path) unless claimed
    end
end

# The return value of every Manager#call. Controllers branch on #success?
# instead of reaching into whatever object the manager happened to touch.
class ManagerResult
  attr_reader :object, :errors

  def initialize(success:, object: nil, errors: [])
    @success = success
    @object = object
    @errors = Array(errors)
  end

  def success?
    @success
  end

  def failure?
    !success?
  end
end

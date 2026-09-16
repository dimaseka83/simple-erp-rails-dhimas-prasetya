# One Manager per controller, not per action — each public class method
# here corresponds to one controller action. Managers own business logic
# and every read/write to the database; controllers only call one of these
# methods and branch on the result.
class ApplicationManager
  class << self
    private
      def success(object = nil)
        ManagerResult.new(success: true, object: object)
      end

      def failure(*errors)
        ManagerResult.new(success: false, errors: errors)
      end

      # For a failed save/update: carries the record itself (with its
      # validation errors already populated) so the controller can
      # re-render the form bound to it, instead of losing what the user typed.
      def invalid(record)
        ManagerResult.new(success: false, object: record, errors: record.errors.full_messages)
      end
  end
end

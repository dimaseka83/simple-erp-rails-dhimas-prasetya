# Managers own business logic and every read/write to the database.
# Controllers only build one of these from params and branch on the result;
# they never call .save, .create!, or .update on a model directly.
class ApplicationManager
  def self.call(...)
    new(...).call
  end

  private
    def success(object = nil)
      ManagerResult.new(success: true, object: object)
    end

    def failure(*errors)
      ManagerResult.new(success: false, errors: errors)
    end
end

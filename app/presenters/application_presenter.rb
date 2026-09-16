# Presenters hold view logic too complex for a template: branching on
# state to pick CSS classes, formatting, anything beyond "call a helper".
# Haml should read top to bottom with no inline Ruby conditionals.
class ApplicationPresenter
  def initialize(view)
    @view = view
  end

  private
    attr_reader :view
end

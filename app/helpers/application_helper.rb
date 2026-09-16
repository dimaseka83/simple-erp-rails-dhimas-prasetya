module ApplicationHelper
  # Pair with RequestUuidProtection#protect_from_duplicate_requests on the
  # controller action this form submits to.
  def request_uuid_field
    hidden_field_tag :request_uuid, SecureRandom.uuid
  end

  # A plain, unstyled <button> whose only content is an icon — the
  # sidebar hamburger, the theme toggle. Keeps the type/aria-label/data
  # attribute boilerplate out of the .haml call site.
  def icon_button(css_class:, aria_label:, data: {}, &block)
    content_tag(:button, capture(&block), type: "button", "aria-label": aria_label, class: css_class, data: data)
  end
end

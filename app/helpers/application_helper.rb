# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def avatar_tag(user)
    hash = Digest::MD5.hexdigest(user.email)
    image_tag "https://www.gravatar.com/avatar/#{hash}", class: "c-avatar"
  end

  def icon_tag(name, options = {})
    return if name.blank?

    size = options.delete(:size)
    title = options.delete(:title)
    is_active = options.delete(:active)
    is_emphasis = options.delete(:emphasis)

    size_class = size.blank? ? "" : "c-icon--#{size}"
    active_class = is_active ? "c-icon--active" : ""
    emphasis_class = is_emphasis ? "c-icon--emphasis" : ""
    icon_class = ["c-icon", size_class, active_class, emphasis_class, options.delete(:class)].join(" ")

    tag.svg(
      fill: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: icon_class,
      **options
    ) do
      tag.title(title) + tag.use("xlink:href": "##{name}")
    end
  end

  def cover_image_url_for(object, size: :medium, default: false)
    return unless object.respond_to?(:cover_image)

    sizes_options = %i[small medium large]
    size = size.in?(sizes_options) ? size : :medium
    default_cover_url = "#{root_url}images/default_#{object.class.name.downcase}_#{size}.png"

    return default_cover_url if default

    object.has_cover_image? ? full_url_for(object.cover_image.variant(size)) : default_cover_url
  end

  def cover_image_tag(object, size: :medium, **options)
    data_attribute = {
      "controller" => "cover-image",
      "cover-image-default-url-value" => cover_image_url_for(object, size: size, default: true)
    }.merge(options.delete(:data) || {})

    image_tag(
      cover_image_url_for(object, size: size),
      data: data_attribute,
      **options
    )
  end

  def loader_tag(size: "")
    size_class = size.blank? ? "" : "c-loader--#{size}"
    tag.div class: "o-animation-spin c-loader #{size_class}"
  end

  def empty_alert_tag(has_icon: false, has_overlay: true)
    render partial: "shared/empty_alert", locals: {has_icon: has_icon, has_overlay: has_overlay}
  end

  def format_duration(sec)
    time = Time.at(sec).utc
    (sec > 1.hour) ? time.strftime("%T") : time.strftime("%M:%S")
  end

  def format_number(number)
    number_to_human(number, units: {thousand: "K", million: "M", billion: "B"}, precision: 1, significant: false)
  end

  def page_title_tag(title)
    title_suffix = " - #{t(:app_name)}"
    title = "#{title}#{title_suffix unless native_app? || dialog?}"

    content_for(:title, title)
  end

  def current_url
    url_for(only_path: false)
  end
end

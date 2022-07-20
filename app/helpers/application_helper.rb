# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def avatar_tag(user)
    hash = Digest::MD5.hexdigest(user.email)
    image_tag "https://www.gravatar.com/avatar/#{hash}", class: "c-avatar"
  end

  def icon_tag(name, options = {})
    return if name.blank?

    size_class = options[:size].blank? ? "" : "c-icon--#{options[:size]}"
    icon_class = ["c-icon", size_class, options[:class]].join(" ")

    tag.svg(
      fill: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: icon_class
    ) do
      tag.title(options[:title]) + tag.use('xlink:href': "##{name}")
    end
  end

  def image_url_for(object, size: "")
    sizes_options = %w[small medium large]
    size = size.in?(sizes_options) ? size : "medium"

    object.image.send(size).url
  end

  def loader_tag(size: "")
    size_class = size.blank? ? "" : "c-loader--#{size}"
    tag.div class: "o-animation-spin c-loader #{size_class}"
  end

  def empty_alert_tag(has_icon: false, has_overlay: true)
    render partial: "shared/empty_alert", locals: {has_icon: has_icon, has_overlay: has_overlay}
  end

  def render_flash(type: :success, message: "")
    flash[type] = message unless message.blank?
    turbo_stream.update "turbo-flash", partial: "shared/flash"
  end

  def format_duration(sec)
    time = Time.at(sec).utc
    sec > 1.hour ? time.strftime("%T") : time.strftime("%M:%S")
  end

  def is_active?(controller: "", path: "")
    params[:controller].in?(Array(controller)) || (path.is_a?(Regexp) ? (path =~ request.path) : (path == request.path))
  end

  def playlist_songs_for_path(playlist, options = {})
    return current_playlist_songs_path(options) if playlist.current?
    return favorite_playlist_songs_path(options) if playlist.favorite?

    playlist_songs_path(playlist, options)
  end

  def shelf_grid_tag(**options, &block)
    class_option = "o-grid o-grid--gap-medium #{options[:class]}"
    tag_options = options.merge(
      :class => class_option,
      "cols@narrow" => 2,
      "cols@extra-small" => 3,
      "cols@small" => 2,
      "cols@medium" => 3,
      "cols@large" => 4,
      "cols@extra-large" => 5,
      "cols@wide" => 6,
      "cols@extra-wide" => 7
    )

    tag.div(**tag_options, escape: false, &block)
  end

  def page_title_tag(title)
    content_for :title, title
  end
end

# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def avatar_tag(user)
    hash = Digest::MD5.hexdigest(user.email)
    image_tag "https://www.gravatar.com/avatar/#{hash}", class: 'avatar'
  end

  def icon_tag(name, options = {})
    return if name.blank?

    size_class = options[:size].blank? ? '' : "icon--#{options[:size]}"
    icon_class = ['icon', size_class, options[:class]].join(' ')

    raw "<svg fill='currentColor'
      stroke-width='2'
      stroke-linecap='round'
      stroke-linejoin='round'
      class='#{icon_class}'>
      <title>#{options[:title]}</title>
      <use xlink:href='##{name}'/></svg>"
  end

  def image_url_for(object, size: '')
    sizes_options = %w(small medium large)
    size = size.in?(sizes_options) ? size : 'medium'

    object.image.send(size).url
  end

  def loader_tag(size: '', expand: false)
    size_class = size.blank? ? '' : "loader--#{size}"
    raw "<div class='loader #{size_class} #{'loader--expand' if expand}'></div>"
  end

  def empty_alert_tag(has_icon: false)
    render partial: 'shared/empty_alert', locals: { has_icon: has_icon }
  end

  def render_flash
    render 'shared/flash.js.erb'
  end

  def render_playlist(html)
    render partial: 'shared/playlist.js.erb', locals: { html: html }
  end

  def format_duration(sec)
    time = Time.at(sec)
    sec > 1.hour ? time.strftime('%T') : time.strftime('%M:%S')
  end

  def is_active?(controller: '', path: '')
    params[:controller].in?(Array(controller)) || (path.is_a?(Regexp) ? (path =~ request.path) : (path == request.path))
  end

  # Because pagy gem method pagy_next_url return url base on request url,
  # but sometime we want specify base url. So this is what this method doing.
  def next_url_for_path(path, pagy)
    return unless pagy.next

    url = URI.parse(path); url_query = Rack::Utils.parse_query url.query
    url.query = Rack::Utils.build_query url_query.merge(pagy.vars[:page_param].to_s => pagy.next)
    url.to_s
  end
end

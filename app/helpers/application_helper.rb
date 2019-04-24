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
    sizes_options = { small: 200, medium: 300, large: 400 }
    size = sizes_options[size.to_sym] || sizes_options[:medium]
    default_image_name = "default_#{object.class.name.downcase}"

    if size
      image_size = "#{size}x#{size}"
      image_variant_options = { resize: "#{image_size}^", gravity: 'Center', extent: image_size }

      object.image.attached? ? url_for(object.image.variant(image_variant_options)) : "/images/#{default_image_name}#{image_size}.png"
    else
      object.image.attached? ? url_for(object.image) : "/images/#{default_image_name}.png"
    end
  end

  def loader_tag(size: '')
    size_class = size.blank? ? '' : "loader--#{size}"
    raw "<div class='loader #{size_class}'></div>"
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

  def render_main_content(html)
    render partial: 'shared/main.js.erb', locals: { html: html }
  end

  def formatDuration(sec)
    time = Time.at(sec)
    sec > 1.hour ? time.strftime('%T') : time.strftime('%M:%S')
  end

  def is_active?(controller: '', path: '')
    controller == params[:controller] || current_page?(path)
  end
end

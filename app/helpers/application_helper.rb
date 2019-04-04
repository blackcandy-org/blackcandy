# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def avatar_tag(user)
    hash = Digest::MD5.hexdigest(user.email)
    image_tag "https://www.gravatar.com/avatar/#{hash}", class: 'avatar'
  end

  def icon_tag(name, options = {})
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

    raw "<div class='loader #{size_class}'>
      <div class='loader__beat loader__beat--odd'></div>
      <div class='loader__beat loader__beat--even'></div>
      <div class='loader__beat loader__beat--odd'></div></div>"
  end

  def empty_alert_tag
    content_tag(:div, t('text.no_items'), class: 'display__justify-align-center display__full-height')
  end

  def render_flash
    render 'shared/flash.js.erb'
  end

  def duration(sec)
    minutes = (sec / 60) % 60
    seconds = sec % 60

    [minutes, seconds].map do |time|
      time.round.to_s.rjust(2, '0')
    end.join(':')
  end

  def is_active?(controller)
    controller == params[:controller]
  end
end

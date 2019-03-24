# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def avatar(user, options = {})
    options[:class] = "#{options[:class]} avatar"
    hash = Digest::MD5.hexdigest(user.email)

    image_tag("https://www.gravatar.com/avatar/#{hash}", options)
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

  def album_image_url(album, size: '')
    sizes_options = { small: 200, medium: 300, large: 400 }
    size = sizes_options[size.to_sym]

    if size
      album.image.attached? ? url_for(album.image.variant(resize: "#{size}x#{size}")) : "/images/default_album#{size}x#{size}.png"
    else
      album.image.attached? ? url_for(album.image) : '/images/default_album.png'
    end
  end

  def spinner_tag(size: '')
    size_class = size.blank? ? '' : "spinner--#{size}"

    raw "<div class='spinner #{size_class}'>
      <div class='spinner__beat spinner__beat--odd'></div>
      <div class='spinner__beat spinner__beat--even'></div>
      <div class='spinner__beat spinner__beat--odd'></div></div>"
  end

  def empty_alert_tag
    content_tag(:div, t('text.no_items'), class: 'display__justify-align-center display__full-height')
  end

  def render_flash
    render 'shared/flash'
  end
end

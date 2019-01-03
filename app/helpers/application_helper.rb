# frozen_string_literal: true

module ApplicationHelper
  def avatar(user, options = {})
    options[:class] = "#{options[:class]} avatar"
    hash = Digest::MD5.hexdigest(user.email)

    image_tag("https://www.gravatar.com/avatar/#{hash}", options)
  end

  def icon_tag(name, size: '', title: '')
    size_class = size.blank? ? '' : "icon--#{size}"

    raw "<svg fill='none'
      stroke='currentColor'
      stroke-width='2'
      stroke-linecap='round'
      stroke-linejoin='round'
      class='icon #{ size_class }'>
      <title>#{ title }</title>
      <use xlink:href='#{ asset_pack_path 'images/feather-sprite.svg' }##{name}'/></svg>"
  end
end

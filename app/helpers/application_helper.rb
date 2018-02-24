module ApplicationHelper
  def avatar(user, options = {})
    options[:class] = "#{options[:class]} avatar"
    hash = Digest::MD5.hexdigest(user.email)

    image_tag("https://www.gravatar.com/avatar/#{hash}", options)
  end
end

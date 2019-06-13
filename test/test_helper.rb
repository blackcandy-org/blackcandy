# frozen_string_literal: true

require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'
require 'taglib'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def new_user(attributes = {})
    User.new({ password: 'foobar' }.merge(attributes))
  end

  def clear_media_data
    Artist.destroy_all
    Album.destroy_all
    Song.destroy_all
  end

  def update_media_tag(file_path, attributes = {})
    TagLib::FileRef.open(file_path.to_s) do |file|
      unless file.null?
        tag = fileref.tag

        attributes.each do |key, value|
          tag.send(key.to_sym, value)
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    assert_login_access(url: root_url) do
      assert_redirected_to albums_url
    end
  end
end

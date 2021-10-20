# frozen_string_literal: true

require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    assert_login_access(url: search_url(query: 'test')) do
      assert_response :success
    end
  end
end

# frozen_string_literal: true

require "application_system_test_case"

class SearchSystemTest < ApplicationSystemTestCase
  setup do
    login_as users(:visitor1)
  end

  test "show search results" do
    fill_in "search_input", with: "artist"
    find(:test_id, "search_input").send_keys(:enter)

    assert_text('Search results for "artist"')
  end

  test "can not request search when query text is empty" do
    fill_in "search_input", with: ""
    find(:test_id, "search_input").send_keys(:enter)

    assert_no_text('Search results for "artist"')
    assert_no_current_path(search_url)
  end
end

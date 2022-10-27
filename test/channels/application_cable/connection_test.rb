# frozen_string_literal: true

require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with cookies" do
    cookies.signed[:user_id] = users(:visitor1).id
    connect

    assert_equal connection.current_user, users(:visitor1)
  end

  test "rejects connection without cookies" do
    assert_reject_connection { connect }
  end
end

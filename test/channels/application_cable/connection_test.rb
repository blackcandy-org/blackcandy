# frozen_string_literal: true

require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with session" do
    session = users(:visitor1).sessions.create!
    cookies.signed[:session_id] = session.id

    connect
    assert_equal connection.current_user, users(:visitor1)
  end

  test "rejects connection without session" do
    assert_reject_connection { connect }
  end
end

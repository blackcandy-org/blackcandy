require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "should build from user credential" do
    session = Session.build_from_credential(email: users(:admin).email, password: "foobar")
    assert session.valid?
  end

  test "should build from user credential with deprecated_password_salt" do
    user = users(:visitor1)
    assert_not_nil user.deprecated_password_salt

    session = Session.build_from_credential(email: user.email, password: "foobar")
    assert session.valid?
  end

  test "should not build from invalid user credential" do
    session = Session.build_from_credential(email: "invalid", password: "foobar")
    assert_not session.valid?

    session = Session.build_from_credential(email: users(:admin).email, password: "invalid")
    assert_not session.valid?
  end

  test "should find current info before create" do
    Current.ip_address = "test_ip"
    Current.user_agent = "test_user_agent"

    session = Session.create(user: users(:visitor1))
    assert_equal "test_ip", session.ip_address
    assert_equal "test_user_agent", session.user_agent
  end

  test "should remove deprecated_password_salt after build from user credential with deprecated_password_salt successfully" do
    user = users(:visitor1)
    assert_not_nil user.deprecated_password_salt

    session = Session.build_from_credential(email: user.email, password: "foobar")
    assert session.valid?
    assert_nil user.reload.deprecated_password_salt

    # After remove deprecated_password_salt, user should still be able to login with same password
    session = Session.build_from_credential(email: user.email, password: "foobar")
    assert session.valid?
  end
end

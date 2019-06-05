# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # From https://en.wikipedia.org/wiki/Email_address#Examples
  INVALID_EMAIL_ADDRESSES = %w(
    Abc.example.com
    a"b(c)d,e:f;g<h>i[j\k]l@example.com
    just"not"right@example.com
    this is"not\allowed@example.com
    this\ still\"not\\allowed@example.com)

  test 'should have valid email' do
    assert new_user(email: 'test@test.com').valid?

    INVALID_EMAIL_ADDRESSES.each do |email|
      assert_not false, new_user(email: email).valid?
    end
  end

  test 'the length of password should more than 6' do
    assert_not new_user(email: 'test@test.com', password: 'foo').valid?
  end

  test 'should downcase email when create' do
    assert_equal 'test@test.com', User.create(email: 'TEST@test.com', password: 'foobar').email
  end
end

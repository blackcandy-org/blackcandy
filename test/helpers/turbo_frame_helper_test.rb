# frozen_string_literal: true

require "test_helper"

class TurboFrameHelperTest < ActionView::TestCase
  include DialogHelper

  test "turbo frame target hands a form to Turbo and keeps htmx off it" do
    form = Nokogiri::HTML5.fragment(
      button_to("Play", "/play", form: turbo_frame_target("turbo-playlist", delegated_action: "turbo:submit-start->songs#checkBeforePlay"))
    ).at("form")

    assert_equal "false", form["hx-boost"]
    assert_equal "true", form["data-turbo"]
    assert_equal "turbo-playlist", form["data-turbo-frame"]
    assert_equal "turbo:submit-start->songs#checkBeforePlay", form["data-delegated-action"]
  end

  test "dialog link loads into the dialog frame without a Turbo history entry" do
    link = Nokogiri::HTML5.fragment(dialog_link_to("About", "/about", class: "c-dropdown__item")).at("a")

    assert_equal "false", link["hx-boost"]
    assert_equal "true", link["data-turbo"]
    assert_equal "turbo-dialog", link["data-turbo-frame"]
    assert_nil link["data-turbo-action"]
    assert_equal "c-dropdown__item", link["class"]
  end
end

# frozen_string_literal: true

require "test_helper"

class Song::Lyrics::ParserTest < ActiveSupport::TestCase
  test "should parse synced lines" do
    lines = parse_lines("[00:01.50]first\n[01:02]second")

    assert_equal [ 1.5, 62.0 ], lines.map(&:time)
    assert_equal [ "first", "second" ], lines.map(&:content)
  end

  test "should sort synced lines by time" do
    lines = parse_lines("[00:02.00]second\n[00:01.00]first")

    assert_equal [ "first", "second" ], lines.map(&:content)
  end

  test "should parse line with multiple time tags into a line for each time" do
    lines = parse_lines("[00:01.00][00:03.00]repeated")

    assert_equal [ 1.0, 3.0 ], lines.map(&:time)
    assert_equal [ "repeated", "repeated" ], lines.map(&:content)
  end

  test "should parse plain lines when no line has time tag" do
    lines = parse_lines("first\nsecond")

    assert_equal [ nil, nil ], lines.map(&:time)
    assert_equal [ "first", "second" ], lines.map(&:content)
  end

  test "should ignore plain lines when some lines have time tag" do
    lines = parse_lines("plain\n[00:01.00]synced")

    assert_equal [ "synced" ], lines.map(&:content)
  end

  test "should ignore metadata lines" do
    lines = parse_lines("[ar:Artist]\n[ti:Title]\nfirst")

    assert_equal [ "first" ], lines.map(&:content)
  end

  test "should ignore blank lines" do
    lines = parse_lines("first\n\n   \nsecond")

    assert_equal [ "first", "second" ], lines.map(&:content)
  end

  test "should remove word time tags from content" do
    lines = parse_lines("[00:01.00]<00:01.00>first <00:02.00>word")

    assert_equal [ "first word" ], lines.map(&:content)
  end

  test "should shift time by offset tag" do
    lines = parse_lines("[offset:+500]\n[00:02.00]first")

    assert_equal [ 1.5 ], lines.map(&:time)
  end

  test "should not shift time below zero by offset tag" do
    lines = parse_lines("[offset:+5000]\n[00:02.00]first")

    assert_equal [ 0 ], lines.map(&:time)
  end

  test "should get no lines from blank text" do
    assert_empty parse_lines(nil)
    assert_empty parse_lines("")
  end

  private

  def parse_lines(text)
    Song::Lyrics::Parser.new(text).lines
  end
end

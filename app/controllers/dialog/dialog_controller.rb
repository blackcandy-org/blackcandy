# frozen_string_literal: true

module Dialog
  class DialogController < ApplicationController
    layout proc { "dialog" unless turbo_native? }
  end
end

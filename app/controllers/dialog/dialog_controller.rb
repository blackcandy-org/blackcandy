# frozen_string_literal: true

module Dialog
  class DialogController < ApplicationController
    layout proc { "dialog" unless native_app? }
  end
end

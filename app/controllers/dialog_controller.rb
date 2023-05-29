# frozen_string_literal: true

class DialogController < ApplicationController
  layout proc { "dialog" unless turbo_native? }
end

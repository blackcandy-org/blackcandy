# frozen_string_literal: true

module StreamConcern
  extend ActiveSupport::Concern

  included do
    before_action :find_stream
  end

  def new
    send_file @stream.file_path
  end

  private

  def find_stream
    @stream = Stream.new(Song.find(params[:song_id]))
  end
end

# frozen_string_literal: true

class Artists::AppearsOnAlbumsController < Artists::AlbumsController
  private
    def find_albums
      @albums = @artist.appears_on_albums
    end
end

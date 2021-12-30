# Rails don't have mime type for flac and wav, so register new mime type for them.
Mime::Type.register "audio/flac", :flac, [], %w[flac]
Mime::Type.register "audio/wav", :wav, [], %w[wav]

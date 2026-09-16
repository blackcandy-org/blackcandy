module ClientDetection
  extend ActiveSupport::Concern

  included do
    helper_method :native_app?, :mobile?, :need_transcode?
  end

  private

  def need_transcode?(song)
    song_format = song.format

    unless native_app?
      return true if !safari? && !song_format.in?(Stream::WEB_SUPPORTED_FORMATS)
      # Non-Safari browsers don't support ALAC format. So we need to transcode it.
      return true if !safari? && song_format == "m4a" && song.lossless?
      return true if safari? && !song_format.in?(Stream::SAFARI_SUPPORTED_FORMATS)
    end

    return true if ios_app? && !song_format.in?(Stream::IOS_SUPPORTED_FORMATS)
    return true if android_app? && !song_format.in?(Stream::ANDROID_SUPPORTED_FORMATS)

    Setting.allow_transcode_lossless? ? song.lossless? : false
  end

  def native_app?
    ios_app? || android_app?
  end

  def mobile?
    Current.session&.browser&.device&.mobile?
  end

  def ios_app?
    Current.session&.ios?
  end

  def android_app?
    Current.session&.android?
  end

  def safari?
    Current.session&.browser&.safari?
  end
end

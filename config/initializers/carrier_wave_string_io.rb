# https://github.com/carrierwaveuploader/carrierwave/wiki/How-to%3A-Upload-from-a-string-in-Rails-3-or-later
class CarrierWaveStringIO < StringIO
  attr_accessor :filepath

  def initialize(*args)
    super(*args[1..-1])
    @filepath = args[0]
  end

  def original_filename
    File.basename(@filepath)
  end
end

if Rails.env.test? || Rails.env.cucumber?
  class TestImageDownloader < CarrierWave::Downloader::Base
    # Disable SSRF protection for CarrierWave remote file download test.
    # See: https://github.com/carrierwaveuploader/carrierwave/issues/2531
    def skip_ssrf_protection?(uri)
      true
    end
  end

  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
    config.downloader = TestImageDownloader
  end
end

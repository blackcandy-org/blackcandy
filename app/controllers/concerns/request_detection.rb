module RequestDetection
  extend ActiveSupport::Concern

  included do
    helper_method :dialog?
    before_action :find_current_request_details
  end

  private

  def dialog?
    is_a? Dialog::ApplicationController
  end

  def api_request?
    request.format.json?
  end

  def find_current_request_details
    Current.ip_address = request.ip
    Current.user_agent = request.user_agent
  end
end

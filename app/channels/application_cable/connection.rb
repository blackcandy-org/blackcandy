module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_current_user
    end

    private

    def find_current_user
      if (session = Session.find_by(id: cookies.signed[:session_id]))
        session.user
      else
        reject_unauthorized_connection
      end
    end
  end
end

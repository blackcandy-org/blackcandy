json.call(session, :id, :user_id, :ip_address, :user_agent, :created_at)
json.email session.user.email
json.is_current session.current?

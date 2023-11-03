json.user do
  json.call(@session.user, :id, :email, :is_admin)
  json.api_token @session.signed_id
end

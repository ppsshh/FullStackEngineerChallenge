paths session: '/session'

post :session do
  u = User.find_or_create_by(login: params[:login])
  session[:user_id] = u.id
  redirect path_to(:index)
end

delete :session do
  session.delete(:user_id)
  halt 200
end

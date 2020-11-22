paths review: '/review',
  feedback: '/feedback',
  assignments: '/assignments'

def parametrize(params)
  payload = params
  payload = JSON.parse(request.body.read).symbolize_keys unless params[:path]
  return payload
end

get :review do
  protect!
  halt(403, "Access denied") unless Assignment.find_by(user: current_user, review_id: params[:review_id]) || current_user.admin?
  review = Review.find(params[:review_id])
  return review.to_hash.merge({
    feedbacks: review.feedbacks.map{|f| f.to_hash}
  }).to_json
end

post :review do
  protect!
  payload = parametrize(params)
  review = Review.create(content: payload[:message], user: current_user)
  Assignment.create(review: review, user: current_user, fulfilled: true)
  return review.to_hash.to_json
end

post :feedback do
  protect!
  payload = parametrize(params)
  halt(403, "Access denied") unless Assignment.find_by(user: current_user, review_id: payload[:review_id]) || current_user.admin?
  feedback = Feedback.create(user: current_user, review_id: payload[:review_id], content: payload[:message])
  return feedback.to_hash.to_json
end

get :assignments do
  protect!
  review = Review.find(params[:review_id])
  assignments = review.assignments
  if current_user.admin?
    User.all.order(login: :asc).map do |u|
      {
        user: u.login,
        assigned: assignments.find_index{|a| a.user_id == u.id} != nil
      }
    end.to_json
  else
    assignments.map do |a|
      {
        user: a.user.login,
        assigned: true
      }
    end.to_json
  end
end
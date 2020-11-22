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
  assignment = Assignment.create(review: review, user: current_user, fulfilled: true)
  return review.to_hash.merge(
    current_user.admin? ? {assignments: assignments_hash([assignment], true)} : {}
  ).to_json
end

post :feedback do
  protect!
  payload = parametrize(params)
  halt(403, "Access denied") unless Assignment.find_by(user: current_user, review_id: payload[:review_id]) || current_user.admin?
  feedback = Feedback.create(user: current_user, review_id: payload[:review_id], content: payload[:message])
  assignment = Assignment.find_by(review_id: payload[:review_id], user: current_user)
  assignment.update(fulfilled: true) if assignment.present? && assignment.fulfilled == false
  return feedback.to_hash.to_json
end

def assignments_hash(assignments, is_admin)
  if is_admin
    User.all.order(login: :asc).map do |u|
      assignment = assignments.find{|a| a.user_id == u.id}
      {
        user_id: u.id,
        user: u.login,
        assigned: assignment.present?,
        fulfilled: assignment.try(:fulfilled),
      }
    end
  else
    assignments.map do |a|
      {
        user_id: a.user.id,
        user: a.user.login,
        assigned: true,
        fulfilled: a.fulfilled,
      }
    end
  end
end

get :assignments do
  protect!
  review = Review.find(params[:review_id])
  assignments_hash(review.assignments, current_user.admin?).to_json
end

post :assignments do
  protect!
  halt(403, "Access denied") unless current_user.admin?
  payload = parametrize(params)
  if payload[:assigned] == true
    Assignment.create(
      review_id: payload[:review_id],
      user_id: payload[:user_id],
      fulfilled: Feedback.where(review_id: payload[:review_id], user_id: payload[:user_id]).present?
      )
  else
    Assignment.where(review_id: payload[:review_id], user_id: payload[:user_id]).destroy_all
  end
  assignments_hash(Assignment.where(review_id: payload[:review_id]), current_user.admin?).to_json
end
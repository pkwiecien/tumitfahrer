class Api::V2::FeedbacksController < ApiController
  respond_to :json, :xml

  # POST /api/v2/feedback
  def create
    feedback = Feedback.create!(user_id: params[:user_id], title: params[:title],
                                content: params[:content])
    if feedback.nil?
      return render json: {:message => "feedback could not be saved"}, status: :bad_request
    else
      return render json: {:message => "feedback submitted"}, status: :created
    end

  end

end

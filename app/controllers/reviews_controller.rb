class ReviewsController < ApplicationController
  before_action :require_login

  def create
    @movie = Movie.find(params[:movie_id])

    @review = current_user.reviews.build(review_params)
    @review.movie = @movie

    if @review.save
      redirect_to movie_path(@movie), notice: "Your review has been submitted!"
    else
      redirect_to movie_path(@movie), alert: "Review cannot be empty."
    end
  end

  private

  def review_params
    params.require(:review).permit(:content)
  end

  def require_login
    unless current_user
      redirect_to new_session_path, alert: "Please sign in to write a review."
    end
  end
end


class HomeController < ApplicationController
  before_action :require_login

  def index
    tmdb = TmdbService.new

    begin
      popular_data = tmdb.popular_movies

      @movies = popular_data["results"].first(12).map do |movie|
        tmdb.save_movie(movie)
      end

    rescue TmdbService::ConnectionError
      @movies = Movie.order(created_at: :desc).limit(12)

      if @movies.any?
        flash.now[:notice] = "You are offline. Showing previously saved movies."
      else
        flash.now[:alert] = "No internet connection and no saved movies available."
      end
    end

    @recent_reviews = Review.includes(:user, :movie)
                            .order(created_at: :desc)
                            .limit(6)
  end

  private

  def require_login
    unless current_user
      redirect_to new_session_path, alert: "Please sign in first."
    end
  end
end

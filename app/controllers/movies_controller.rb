
class MoviesController < ApplicationController
  def search
    query = params[:query].to_s.strip

    if query.blank?
      flash[:alert] = "Please enter a movie name."
      redirect_to root_path
      return
    end

    begin
      @movies = TmdbService.new.find_or_fetch_movies(query)

    rescue TmdbService::ConnectionError
      flash[:alert] = "No internet connection. Please connect to the internet to search movies."
      redirect_to root_path
      return
    end

    if @movies.blank?
      flash[:alert] = "No movies found matching your search."
      redirect_to root_path
    end
  end

  def show
    @movie = Movie.find(params[:id])
    @reviews = @movie.reviews.includes(:user).order(created_at: :desc)
  end
end

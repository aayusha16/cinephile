require "uri"
require "net/http"
require "json"

class TmdbService
  class ConnectionError < StandardError; end

  BASE_URL = "https://api.themoviedb.org/3"

  def initialize
    @token = ENV["TMDB_API_KEY"]
  end  # initialize method  / runs automatically whenever we create a new instance

  def popular_movies
    get("/movie/popular")
  end # this is used in homecontroller

  def save_movie(tmdb_movie)
    Movie.find_or_create_by(tmdb_id: tmdb_movie["id"]) do |movie|
      movie.title = tmdb_movie["title"]
      movie.overview = tmdb_movie["overview"]
      movie.poster_path = tmdb_movie["poster_path"]
      movie.release_date = tmdb_movie["release_date"].presence
      movie.vote_average = tmdb_movie["vote_average"]
    end
  end

  def search_movies(query)
    get("/search/movie?query=#{URI.encode_www_form_component(query)}")
  end

  def find_or_fetch_movies(query)
    normalized_query = query.to_s.strip.downcase.squish

    # Check PostgreSQL for previously cached search
    cached_search = MovieSearch.includes(:movies)
                               .find_by(query: normalized_query)

    return cached_search.movies if cached_search

    # Fetch from TMDB if search is not cached
    response = search_movies(query)

    # Save returned movies
    movies = response.fetch("results", []).map do |tmdb_movie|
      save_movie(tmdb_movie)
    end

    # Cache the search and its associated movies
    MovieSearch.create!(
      query: normalized_query,
      movies: movies
    )

    movies
  end

  private


  def get(endpoint)
    uri = URI("#{BASE_URL}#{endpoint}")

    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{@token}"
    request["accept"] = "application/json"

    response = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: true,
      open_timeout: 5,
      read_timeout: 5
    ) do |http|
      http.request(request)
    end

    JSON.parse(response.body)

  rescue SocketError, SystemCallError,
         Net::OpenTimeout, Net::ReadTimeout,
         Net::WriteTimeout, OpenSSL::SSL::SSLError,
         Timeout::Error => e

    raise ConnectionError, e.message
  end
end

class MovieSearch < ApplicationRecord
  has_many :movie_search_results, dependent: :destroy
  has_many :movies, through: :movie_search_results

  validates :query, presence: true
end

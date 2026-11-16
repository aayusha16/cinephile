class Movie < ApplicationRecord
  has_many :movie_search_results, dependent: :destroy
  has_many :movie_searches, through: :movie_search_results

  has_many :reviews, dependent: :destroy

  validates :tmdb_id, presence: true, uniqueness: true
  validates :title, presence: true
end

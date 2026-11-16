class CreateMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :movies do |t|
      t.integer :tmdb_id, null: false
      t.string :title, null: false
      t.text :overview
      t.string :poster_path
      t.date :release_date
      t.float :vote_average

      t.timestamps
    end

    add_index :movies, :tmdb_id, unique: true
  end
end

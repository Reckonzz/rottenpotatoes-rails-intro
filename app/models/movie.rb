class Movie < ActiveRecord::Base
  def self.all_ratings
    return ['G','PG','PG-13','R']
  end 

  def self.with_ratings(ratings_list)
    if ratings_list == nil
      return self.all
    end 
    self.where("rating IN (?)", ratings_list)
  end
end
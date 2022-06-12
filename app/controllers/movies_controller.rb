class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    

    if !session.key?(:ratings) || !session.key?(:sort_by)
      @all_ratings_hash = Hash[@all_ratings.collect {|key| [key, '1']}]
      session[:ratings] = @all_ratings_hash if !session.key?(:ratings)
      session[:sort_by] = '' if !session.key?(:sort_by)
      redirect_to movies_path(:ratings => @all_ratings_hash, :sort_by => '') and return
    end
    
    if !params.has_key?(:ratings) || !params.has_key?(:sort_by)
      ratings = params.has_key?(:ratings) ? params[:ratings] : session[:ratings]
      sort_by = params.has_key?(:sort_by) ? params[:sort_by] : session[:sort_by]
      redirect_to movies_path(:ratings => ratings, :sort_by => sort_by) and return
    end

    @ratings_to_show = params[:ratings] ? params[:ratings].keys : []
    @ratings_to_show_hash = Hash[@ratings_to_show.collect {|key| [key, '1']}]
    @movies = Movie.with_ratings(@ratings_to_show)
    session[:ratings] = params[:ratings]

    column_selected_styles = "hilite bg-warning"
    column_classes = {@title_header=> "", @release_date_header=> ""}

    if params[:sort_by]
      instance_variable_set("@#{params[:sort_by]}_header", column_selected_styles)
      @movies = params[:sort_by] ? @movies.order(params[:sort_by]) : @movies 
      session[:sort_by] = params[:sort_by]
    end     
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
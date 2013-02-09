class PostsController < ApplicationController
  def edit
    @post = Post.find(params[:id])
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(params[:post])
    if @post.save
      flash[:success] = "Post '##{@post.title}' created successfully."
      redirect_to @post
    else
      flash.now[:error] = "Failed to create Post."
      render :new
    end
  end

  def update
    @post = Post.find(params[:id])
    if @post.update_attributes(params[:post])
      flash[:success] = "Post '##{@post.title}' updated successfully."
      redirect_to @post
    else
      flash.now[:error] = "Failed to update Post."
      render :edit
    end
  end

  def destroy
    @post = Post.find(params[:id])
    if current_user == @post.audits.first.user or current_user.is_admin
      @post.destroy
      flash[:success] = "Successfully deleted Post '#{@post.title}'."
      redirect_to Post.first ? Post.last : root_path
    else
      flash.now[:error] = "Failed to delete Post."
      render :show
    end
  end

  def new_or_edit
    if Post.first
      redirect_to Post.last
    else
      redirect_to new_post_path
    end
  end 
end

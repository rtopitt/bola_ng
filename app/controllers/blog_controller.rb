class BlogController < ApplicationController
  
  # GET /blog
  # Via: blog_index_path
  # Avaiable: all
  #
  # Shows all blog posts.
  def index
    @current_tab = 'blog'
    @page_title = "Blog"
    @service = BlogService.active.first
    @posts = @service.posts.published.ordered.with_service.paginate(
      :page => params[:page]
    )
  end

  # GET /blog/:id
  # Via: blog_path(:slug) ou blog_path(:id)
  # Avaiable: all
  #
  # Shows one blog post.
  def show
    @current_tab = 'blog'
    @service = BlogService.active.first
    @post = @service.posts.published.ordered.with_service.find_by_slug(params[:id]) || @service.posts.published.ordered.with_service.find(params[:id])
    @post_context = @post.context
    @page_title = "Blog :: #{@post.title}"
  end
  
end

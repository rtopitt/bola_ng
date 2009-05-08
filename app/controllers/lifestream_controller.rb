class LifestreamController < ApplicationController

  # GET /
  # GET /lifestream
  # Via: root_path
  # Via: lifestream_index_path
  # Avaiable: all
  #
  # Shows the combined lifestream.
  def index
    @current_tab = 'lifestream'
    @page_title = "Lifestream"
    @posts = if current_user
      Post.ordered.with_service.paginate(:page => params[:page])
    else
      Post.published.ordered.with_service.paginate(:page => params[:page])
    end
  end

  # GET /lifestream/:id
  # Via: lifestream_path(:id)
  # Avaiable: all
  #
  # Shows the lifestream of the supplied feed only.
  # TODO: redirecionar para /blog caso service seja o blog_service
  def show
    @current_tab = 'lifestream'
    @service = Service.find_by_slug(params[:id])
    @posts = if current_user
      @service.posts.ordered.with_service.paginate(:page => params[:page])
    else
      @service.posts.published.ordered.with_service.paginate(:page => params[:page])
    end
    @page_title = "Lifestream :: #{@service.name}"
  end

end

class Site::ApplicationController < ApplicationController
  layout 'tt'

  # caches_action :index, cache_path: 'desktop/index', if: Proc.new {
  #   controller_name == 'application'
  # }, :expires_in => 2.hours

  self.page_cache_directory = :domain_cache_directory
  
  caches_page :index

  def index
    @links = Link.where(linkable_id: 0).pc
    @focus = Article.focus
    # @hots = Article.hot
    @articles = Article.recommend
    # @photo_news = Article.photo_news
  end

  def more
    # @articles = Article.recommend(page: params[:page], load: 5)
    @articles = Article.recommend
    html = render_to_string(partial: 'site/application/index_article', layout: false, collection: @articles, as: :article, locals: { lazyload: true, page: params[:page] })
    render json: { html: html }
  end

  def domain_cache_directory
    Rails.root.join("public", request.domain, 'cached_pages')
  end
end

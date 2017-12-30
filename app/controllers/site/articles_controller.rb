class Site::ArticlesController < Site::ApplicationController
  before_action :login_required, only: [:new, :create, :user_articles, :edit, :update, :destroy]
  before_action :find_article, only: [:edit, :update, :destroy]
  
  caches_action :feed, expires_in: 2.hours
  
  self.page_cache_directory = -> { Rails.root.join("public", 'cached_pages') }
  caches_page :index

  caches_action :index, :cache_path => Proc.new { |c| c.request.url + '-desktop' }, :expires_in => 30.minutes, :unless => -> { request.format.json? }
  caches_action :show, :cache_path => Proc.new{ |c| 'articles' + "-#{c.params[:slug]}-" + c.params[:id] + '-desktop' }, :expires_in => 30.minutes

  def index
    @node = Node.find_by!(slug: params[:slug])
    @nodes = @node.root.self_and_descendants
    @articles = Article.where(node_id: @node.self_and_descendants.pluck(:id))
                       .where(approved: true)
                       .order('id DESC')
                       .paginate(page: params[:page], per_page: 20, total_entries: 1000000)

    @links = @node.links.pc
    @channel_keywords = @node.seo_keywords

    title = [@node.name, @node.seo_title.presence || nil].compact.join('_')
    set_meta title: title,
             description: @node.seo_description,
             keywords: @node.seo_keywords

    respond_to do |format|
      format.html {
        if @node.is_column?
          render template: 'site/articles/column'
        end
      }

      format.js {
        html = render_to_string(partial: 'site/application/index_article', collection: @articles, as: :article)
        render json: { html: html }
      }
    end
  end

  def fetch_articles
    @node = Node.find_by!(slug: params[:slug])
    @nodes = @node.root.self_and_descendants
    @articles = Article.where(node_id: @node.self_and_descendants.pluck(:id))
                       .where(approved: true)
                       .order('id DESC')
                       .paginate(page: params[:page], per_page: 10, total_entries: 1000000)
    html = render_to_string(partial: 'site/application/index_article', collection: @articles, as: :article)
    render json: { html: html }
  end

  def show
    @node = Node.find_by!(slug: params[:slug])
    @article = @node.articles.find(params[:id])

    unless @article.approved?
      render :file => 'public/404.html', status: 404, layout: false
      return
    end

    @nodes = @node.self_and_ancestors

    tag_ids = @article.taggings.pluck(:tag_id)
    if tag_ids.any?
      article_ids = Tagging.where(tag_id: tag_ids).order('id DESC').limit(8).pluck(:article_id)
      @more_articles = Article.where(id: article_ids).where.not(id: @article.id).order('id DESC').limit(8).to_a

      if (ct = @more_articles.count) < 8
        more = Article.where(node_id: @nodes.pluck(:id)).where.not(id: @article.id).limit(8 - ct).to_a
        @more_articles = @more_articles + more
      end
    else
      @more_articles = Article.where(node_id: @nodes.pluck(:id)).where.not(id: @article.id).limit(8)
    end

    @channel_keywords = @article.seo_keywords

    set_meta_tags title: @article.format_seo_title,
                  description: @article.seo_description,
                  keywords: @article.seo_keywords

    fresh_when(etag: [@article, Keyword.recent], template: false) 
  end

  def new
    @article = current_user.articles.new
    @article.build_article_body
    set_meta_tags title: "发表文章"
  end

  def create
    set_meta_tags title: "发表文章"

    @article = current_user.articles.new(article_params)
    @article.source = current_user.username
    @article.approved = current_user.review_later?

    if @article.save
      redirect_to user_articles_path
    else
      render action: :new
    end
  end

  def user_articles
    @articles = current_user.articles.order('id DESC').paginate(paginate_params)
    set_meta_tags title: "我的文章"
  end

  def edit
  end

  def update
    if @article.update_attributes(article_params)
      flash[:info] = "修改文章成功"
      redirect_to user_articles_path
    else
      render action: :edit
    end
  end

  def destroy
    @article.destroy
    flash[:info] = "删除文章成功"
    redirect_to user_articles_path
  end

  def search
    url = "#{Setting.baidu_search_host}/cse/search?q=#{CGI::escape(params[:q])}&click=1&s=#{Setting.baidu_search_id}&nsid=1"
    redirect_to url
  end

  def feed
    @articles = Article.includes(:article_body, :node).order('id DESC').limit(200)
    render layout: false
  end 

  private

  def article_params
    params.require(:article).permit(:node_id, :title, :short_title, :thumb, :source, :writer, :seo_title, :seo_keywords, :seo_description, :hot, :focus, :recommend, :linked, :link_word, :article_body_attributes => [:id, :body, :cached_keyword_id, :redirect_url])
  end

  def find_article
    @article = current_user.articles.find params[:id]
  end

  def paginate_params
    { page: params[:page], per_page: 10 }
  end  
end

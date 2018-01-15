class Site::ApplicationController < ApplicationController
  layout 'tt'

  self.page_cache_directory = -> { Rails.root.join("public", 'cached_pages') }
  
  caches_page :site_index
  caches_action :column, :cache_path => Proc.new { |c| c.request.url + '-desktop' }, :expires_in => 10.minutes

  def site_index
    @links = Link.where(linkable_id: 0).pc
    @focus = Article.focus
    @secondary_focus = Article.secondary_focus
    @articles = Article.recommend(page: params[:page])
  end

  def column
    @nodes = Node.where(is_column: true, is_at_top: true).order('sortrank DESC')
    @articles = Article.where(node_id: @nodes.pluck(:id))
                       .where(approved: true).order('id DESC')
                       .paginate(page: params[:page], per_page: 20, total_entries: 10000)

    respond_to do |format|
      format.html {
        render template: 'site/articles/index'
      }

      format.js {
        html = render_to_string(partial: 'site/application/index_article', collection: @articles, as: :article)
        render json: { html: html }
      }
    end
  end

  def more
    @articles = Article.recommend(page: params[:page], load: 10)
    # @articles = Article.recommend
    html = render_to_string(partial: 'site/application/index_article', layout: false, collection: @articles, as: :article, locals: { lazyload: true, page: params[:page] })
    render json: { html: html }
  end
end

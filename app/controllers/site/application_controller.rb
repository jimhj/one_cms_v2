class Site::ApplicationController < ApplicationController
  layout 'site'

  caches_action :index, cache_path: 'desktop/index', expires_in: 2.hours, if: Proc.new {
    controller_name == 'application'
  }

  def index
    @links = Link.where(linkable_id: 0).pc
    @focus = Article.focus
    @topnews = Article.topnews
  end
end

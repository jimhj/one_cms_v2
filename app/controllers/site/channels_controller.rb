class Site::ChannelsController < Site::ApplicationController
  self.page_cache_directory = -> { Rails.root.join("public", 'cached_pages', 'z') }
  caches_page :show

  caches_action :index, :cache_path => Proc.new { |c| c.request.url + '-desktop' }, :expires_in => 6.hours
  caches_action :show, :cache_path => Proc.new { |c| c.request.url + '-desktop' }, :expires_in => 6.hours

  def index
    @channels = Channel.order('sortrank DESC, id DESC').paginate(page: params[:page], per_page: 300)

    set_meta title: '热门专题'
  end

  def show
    @channel = Channel.find_by!(slug: params[:slug])
    @articles = @channel.articles.order('id DESC').paginate(page: params[:page], per_page: 20)

    @channel_keywords = @channel.seo_keywords

    seo_ary = [@channel.name, @channel.seo_keywords.presence || nil].compact
    set_meta title: seo_ary.join('_'),
             description: @channel.seo_description,
             keywords: seo_ary.join(',')
  end
end
class Article < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  
  belongs_to :node
  has_one :article_body, dependent: :destroy
  has_many :taggings
  has_many :tags, through: :taggings

  mount_uploader :thumb, ThumbUploader
  accepts_nested_attributes_for :article_body, allow_destroy: true

  validates_presence_of :node_id, :title
  validates_uniqueness_of :title

  scope :recent, -> { order('id DESC').limit(10) }
  scope :focus, -> { where(focus: true).order('id DESC').limit(3) }
  scope :hot, -> { where(hot: true, thumb: nil).order('id DESC').limit(6) }

  after_create do
    if self.linked?
      self.delay.create_keyword
    end

    self.delay.notify_baidu_spider
  end

  after_update do
    if (changed_attributes.keys.include?('linked') or changed_attributes.keys.include?('link_word')) && self.linked?
      self.delay.create_keyword
    end
  end

  def notify_baidu_spider
    url = "http://www.h4.com.cn/#{node.slug}/#{id}"
    site = RestClient::Resource.new('http://data.zz.baidu.com')
    site['urls?site=www.h4.com.cn&token=2yEYwtNjfx5k5sNB'].post url, :content_type => 'text/plain'
  end

  def create_keyword
    link = "http://www.h4.com.cn/#{node.slug}/#{id}"
    Keyword.create(name: self.link_word, url: link, sortrank: 1000)
  end

  def set_thumb
    return 0 if not self.thumb.blank?
    imgs = Nokogiri::HTML(self.body_html).css('img').collect{ |img| img[:src] }
    return 1 if not imgs.any?
    img = imgs.first.split(Setting.carrierwave.asset_host + '/').last
    return 2 if img.nil?
    img = Rails.root.join('public', img)
    img = MiniMagick::Image.open(img)
    self.thumb = img
    self.save
  end

  def set_description
    self.seo_description = strip_tags(article_body.body).first(200)
    self.save
  end

  def seo_description
    read_attribute(:seo_description) || strip_tags(article_body.try(:body) || '').first(200)
  end

  def self.pic
    node_ids = Node.all.pluck(:id)
    node_ids = node_ids.sample(10)
    articles = Article.where(node_id: node_ids).order('thumb DESC, id DESC')
    articles.limit(5)
  end

  def self.headline
    hot.first
  end

  def self.topnews
    hot[1..-1]
  end

  def analyze_keywords
    rsp = DiscuzKeyword.analyze(title, article_body.body)
    keywords = rsp['total_response']['keyword']['result']['item'].collect{ |h| h.values }.flatten rescue []

    self.tags = keywords.collect do |tag|        
      t = ::Tag.find_or_initialize_by(name: tag)
      t.name = tag
      t.save!
      t
    end

    update_attribute :seo_keywords, keywords.join(',')
  end

  def next
    Article.where("id < ?", id).order("id DESC").first
  end

  def prev
    Article.where("id > ?", id).order("id ASC").first
  end

  def body_html
    # article_body.body_html.presence || article_body.body 
    article_body.replace_keywords
  end

  def keywords
    seo_keywords.split(/,|，/)
  end
end

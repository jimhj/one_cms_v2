class Article < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  
  belongs_to :user
  belongs_to :node
  has_one :article_body, dependent: :destroy
  has_many :taggings
  has_many :tags, through: :taggings
  has_many :picture_assets, -> { where('height >= 100 and width >= 100').order('created_at DESC') }, as: :assetable, class_name: 'RedactorRails::Picture'
  has_many :comments
  
  mount_uploader :thumb, ThumbUploader
  accepts_nested_attributes_for :article_body, allow_destroy: true

  validates_presence_of :node_id, :title
  validates_uniqueness_of :title

  scope :recent, -> { where(approved: true).where(recommend: false).order('id DESC').limit(6) }
  scope :focus, -> { where(approved: true).where(focus: true).order('id DESC').limit(8) }
  scope :secondary_focus, -> { where(approved: true).where(secondary_focus: true).order('id DESC').limit(2) }
  scope :hot, -> { where(approved: true).where(hot: true).order('id DESC').limit(10) }

  scope :with_photo, -> {
    where('pictures_count > 0')
  }
  
  scope :photo_news, -> {
    where(approved: true).where(hot: false).with_photo.order('id DESC').limit(6)
  }

  after_create do
    self.analyze_keywords
    
    if self.linked?
      self.delay.create_keyword
    end

    self.delay.notify_baidu_spider
  end

  before_save do
    self.seo_keywords = (self.seo_keywords.presence || '').split(/,|，/).join(',')
  end

  def analyze_keywords
    words = (self.seo_keywords.presence || '').split(/,|，/)
    self.tags = words.collect do |tag|        
      t = ::Tag.find_or_initialize_by(name: tag)
      t.name = tag
      t.save!
      t
    end 
  end

  after_update do
    if (changed_attributes.keys.include?('linked') or changed_attributes.keys.include?('link_word')) && self.linked?
      self.delay.create_keyword
    end

    self.analyze_keywords
  end

  def notify_baidu_spider
    return if node.blank?

    uri = URI.parse("http://data.zz.baidu.com/urls?site=#{SiteConfig.actived.domain}&token=#{Setting.baidu_notify_token}")
    req = Net::HTTP::Post.new(uri.request_uri)

    url = "http://#{SiteConfig.actived.domain}/#{node.slug}/#{id}"
    req.body = url
    req.content_type = 'text/plain'

    Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
  end

  def create_keyword
    link = "http://#{SiteConfig.actived.domain}/#{node.slug}/#{id}"
    Keyword.create(name: self.link_word, url: link, sortrank: 1000)
  end

  def set_description
    self.seo_description = strip_tags(article_body.body).first(200)
    self.save
  end

  def seo_description
    read_attribute(:seo_description) || strip_tags(article_body.try(:body) || '').first(200)
  end

  def self.topnews
    hot[1..-1]
  end

  # def analyze_keywords
  #   begin
  #     # rsp = DiscuzKeyword.analyze(title, article_body.body)
  #     # keywords = rsp['total_response']['keyword']['result']['item'].collect{ |h| h.values }.flatten rescue []
  #     text =  title
  #     keywords = PullWord.analyze(text)
  #     keywords = keywords.sort_by { |w| w.length }.last(5) || []
  #     p keywords

  #     self.tags = keywords.collect do |tag|        
  #       t = ::Tag.find_or_initialize_by(name: tag)
  #       t.name = tag
  #       t.save!
  #       t
  #     end

  #     update_attribute :seo_keywords, keywords.join(',')
  #   rescue
  #     true
  #   end
  # end

  def pictures
    pictures = self.picture_assets

    return [] if article_body.nil?
    
    if pictures.blank?
      filenames = Nokogiri::HTML(article_body.body).css('img').collect do |img|
        src = img[:src]
        next if src.nil?

        split_host = nil

        if src.include?(Setting.carrierwave.asset_host)
          split_host = Setting.carrierwave.asset_host
        end

        if Setting.carrierwave['legacy_asset_host'].present?
          if src.include?(Setting.carrierwave.legacy_asset_host)
            split_host = Setting.carrierwave.legacy_asset_host
          end
        end

        next if split_host.nil?

        img_path = src.split(split_host + '/').last
        img_path.split('/').last(2).join('/')
      end.compact

      pictures = RedactorRails::Picture.where(data_file_name: filenames).where('width >= 100 and height >= 100')
      pictures.update_all(assetable_type: self.class.name, assetable_id: self.id)
      self.update_column(:pictures_count, pictures.count)
    end

    pictures.collect { |pic| pic.qn_url(:thumb) }
  end

  def bjh_pictures
    pics = if pictures.blank?
      ["https://i2.h4.com.cn/thumb.png"]
    elsif pictures.size >= 3
      pictures.first(3)
    else
      [pictures.first]
    end

    pics.collect do |pic|
      if pic.start_with?('https:') or pic.start_with?('http:')
        pic
      else
        pic = "https:#{pic}"
      end

      pic
    end
  end

  def next
    Article.where("id < ?", id).order("id DESC").first
  end

  def prev
    Article.where("id > ?", id).order("id ASC").first
  end

  def add_watermark_to_html_images(html)
    doc = Nokogiri::HTML(html)
    doc.css('img').each do |img|
      begin
        src = img[:src]
        if src.nil?
          img.remove
          next
        end

        if Setting.carrierwave["legacy_asset_host"].present?
          src = src.gsub(Setting.carrierwave.legacy_asset_host, Setting.qiniu.mirror_host)
        end
        
        src = src.gsub(Setting.carrierwave.asset_host, Setting.qiniu.mirror_host)
        img.set_attribute(:src, "#{src}!content")
      rescue => e
        next
      end
    end
    doc.to_s
  end

  def body_html
    html = article_body.body_html.presence || article_body.body
    article_body.delay.replace_keywords rescue nil
    article_body.delay.restore_remote_images rescue nil
    # add_watermark_to_html_images(html)
    html
  end

  def keywords
    seo_keywords.split(/,|，/)
  end

  def self.recommend(page: 1, load: 20, node_id: nil)
    page = page.to_i
    init_offset = 20
    if page == 1
      offset = 0
    elsif page > 1
      offset = load * (page - 1) + init_offset
    end

    recommends = self.where(recommend: true, approved: true)

    if node_id.present?
      node = Node.find node_id
      node_ids = node.self_and_descendants.pluck(:id)
      recommends = recommends.where(node_id: node_ids)
    end

    recommends = recommends.order('id DESC').offset(offset).limit(load)

    # if recommends.count < load
    #   needs = self.where.not(id: recommends.pluck(:id)).order('id DESC').offset(offset).limit(load - recommends.count)
    # else
    #   needs = []
    # end
    # recommends = recommends.to_a + needs.to_a
  end

  def format_seo_title
    seo_title = self.seo_title.presence || ''
    if seo_title.start_with?(self.title)
      seo_title = seo_title.sub(self.title, '')
    end

    seo_title = [self.title, seo_title]
    seo_title -= ['', nil]
    seo_title.join    
  end

  def source
    s = read_attribute(:source)
    s.presence || '网友'
  end

  def incr_hits
    c = Array.new(10, 1) + Array.new(5, 2) + Array.new(3, 3) + Array.new(2, 4) + [5]
    update_column(:hits, self.hits+c.sample)    
  end
end

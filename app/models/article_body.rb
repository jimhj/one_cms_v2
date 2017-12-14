require 'nokogiri'

class ArticleBody < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  belongs_to :article
  validates_presence_of :body

  after_update do
    if changed_attributes.keys.include?('body')
      update_columns(cached_keyword_id: 0, body_html: self.body)
      self.delay.replace_keywords rescue nil
    end
  end

  before_create do
    self.body = strip_links(self.body)
  end

  after_create do
    self.delay.restore_remote_images
    article.delay.analyze_keywords
    # self.delay.replace_keywords

    if article.seo_description.blank?
      article.set_description
    end
  end

  def replace_keywords
    keywords = Keyword.order('id ASC').select(:id, :name, :url)
    if not cached_keyword_id.zero?
      keywords = keywords.where('id > ?', cached_keyword_id)
    end
    keywords = keywords.limit(3500)

    if keywords.blank?
      return self.body_html || self.body
    end
    
    keywords.to_a.sort { |a, b| b.name.size <=> a.name.size }.each do |keyword|
      begin
        doc = Nokogiri::HTML(self.body_html.presence || self.body)   

        ele = doc.xpath("//text()[not(ancestor::a)][contains(., '#{keyword.name}')]").first
        next if ele.nil?

        link = Nokogiri::XML::Node.new "a", doc
        link.set_attribute(:href, keyword.url)
        link.set_attribute(:class, 'hot-link')
        link.set_attribute(:target, '_blank')
        link.set_attribute(:title, keyword.name)
        link.content = keyword.name

        ele.replace ele.content.sub(/#{keyword.name}/, link.to_html)

        self.body_html = doc.to_html
      rescue => e
        next
      end
    end

    update_columns(cached_keyword_id: keywords.last.try(:id) || 0, body_html: self.body_html)

    self.body_html || self.body
  end


  def restore_remote_images
    doc = Nokogiri::HTML(self.body_html.presence || self.body)
    doc.css('img').each do |img|
      begin
        next if img[:src].include?(Setting.carrierwave.asset_host)

        picture = RedactorRails.picture_model.new
        picture.remote_data_url = img[:src]
        if picture.width.to_i >= 100 && picture.height.to_i >= 100
          picture.assetable = article
        end

        next if not picture.save

        img.set_attribute(:src, picture.url)
        img.set_attribute(:alt, article.title)
      rescue => e
        next
      end
    end

    update_column :body_html, doc.to_s
  end
end

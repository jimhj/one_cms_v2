json.array! @articles do |article|
  photo_url = (article.pictures.first || '').gsub('!thumb', '').sub('//', 'https://').presence || nil
  json.title article.title
  json.description article.seo_description
  json.created_at article.created_at.strftime('%F %T')
  json.url mip_article_url(article).sub('http://', 'https://')
  json.from article.source
  json.comments_count article.comments.count
  json.article_type photo_url.blank? ? 1 : 2
  json.photo_url photo_url
end
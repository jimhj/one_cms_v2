json.array! @articles do |article|
  json.title article.title
  json.description article.seo_description
  json.created_at article.created_at.strftime('%F %T')
  json.url mip_article_url(article).sub('http://', 'https://')
  json.from article.source
  json.photo_url (article.pictures.first || '').gsub('!thumb', '').sub('//', 'https://').presence || nil
end
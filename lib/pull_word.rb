class PullWord
  def self.analyze(text)
    params = {
      source: text,
      param1: 0,
      param2: 0
    }
    rsp = RestClient.post "http://api.pullword.com/post.php", params
    words = rsp.body.split.map{ |w| w.force_encoding('UTF-8') } rescue []
    words.uniq
  end
end
RestClient.log = Rails.logger

class BaiduWord
  def self.analyze(text)
    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36"
    accept = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"
    cookie = "PSTM=1501549632; BIDUPSID=7835297D074E6714E4D3A8F0BE5575A8; __cfduid=d30509a7ec2c4edf80e30fb7be9bcbd141504601873; BAIDUID=23D3B2E45FA0EA5E36C2C75FDE031575:FG=1; H_PS_PSSID=1431_21115_22073; BDORZ=B490B5EBF6F3CD402E515D22BCDA1598; SFSSID=a0jc1mon0uekv5p0nnkrik1k24; SIGNIN_UC=70a2711cf1d3d9b1a82d2f87d633bd8a02668096455; uc_login_unique=093b4d20fe07fbdc44d2fbedf8a69967; uc_recom_mark=cmVjb21tYXJrXzIzODc5ODkz; PSINO=1; FP_UID=77f877bc5eeab775a0e5a12662bf6515"
    url = "http://zhannei.baidu.com/api/customsearch/keywords?title=#{URI::encode(text)}"

    # RestClient.get "http://zhannei.baidu.com/favicon.ico", {
    #   "Referer" => url,
    #   "UserAgent" => user_agent, 
    #   "Accept" => accept, 
    #   "Cookie" => cookie, 
    #   "Upgrade-Insecure-Requests" => 1,
    #   "Pragma" =>"no-cache",
    #   "Accept-Language" => "zh-CN,zh;q=0.9,en;q=0.8,zh-TW;q=0.7,lb;q=0.6,mt;q=0.5,th;q=0.4",
    #   "Cache-Control" => "no-cache"
    # }

    rsp = RestClient.get url, { 
      "UserAgent" => user_agent, 
      "Accept" => accept, 
      "Cookie" => cookie, 
      "Upgrade-Insecure-Requests" => 1,
      "Pragma" =>"no-cache",
      "Accept-Language" => "zh-CN,zh;q=0.9,en;q=0.8,zh-TW;q=0.7,lb;q=0.6,mt;q=0.5,th;q=0.4",
      "Cache-Control" => "no-cache"
    }

    RestClient.get "http://zhannei.baidu.com/favicon.ico", {
      "Referer" => url,
      "UserAgent" => user_agent, 
      "Accept" => accept, 
      "Cookie" => cookie, 
      "Upgrade-Insecure-Requests" => 1,
      "Pragma" =>"no-cache",
      "Accept-Language" => "zh-CN,zh;q=0.9,en;q=0.8,zh-TW;q=0.7,lb;q=0.6,mt;q=0.5,th;q=0.4",
      "Cache-Control" => "no-cache"
    }

    rsp = MultiJson.load(rsp) 

    rsp["result"]["res"]["keyword_list"] rescue []
  end
end
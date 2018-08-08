# Aliyun::Sms.configure do |config|
#   config.access_key_secret = Setting.alisms.secret  # 阿里云接入密钥，在阿里云控制台申请
#   config.access_key_id = Setting.alisms.key         # 阿里云接入 ID, 在阿里云控制台申请
#   config.action = 'SendSms'                    # 默认设置，如果没有特殊需要，可以不改
#   config.format = 'JSON'                       # 短信推送返回信息格式，可以填写 'JSON'或者'XML'
#   config.region_id = 'cn-hangzhou'             # 默认设置，如果没有特殊需要，可以不改      
#   config.sign_name = Setting.alisms.sign_name                 # 短信签名，在阿里云申请开通短信服务时申请获取
#   config.signature_method = 'HMAC-SHA1'        # 加密算法，默认设置，不用修改
#   config.signature_version = '1.0'             # 签名版本，默认设置，不用修改
#   config.sms_version = '2017-05-25'            # 服务版本，默认设置，不用修改
#   config.domain = 'dysmsapi.aliyuncs.com'      # 阿里云短信服务器, 默认设置，不用修改
# end
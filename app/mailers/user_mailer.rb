class UserMailer < ActionMailer::Base
  def activation_email(token)
    @url = active_user_url(token.token)

    mail(
      from: '链世界 <kefu@7234.cn>',
      to: token.receiver, 
      subject: "链世界 - 7234.cn 注册确认"
    )
  end
end
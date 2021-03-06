class Site::WelcomeController < Site::ApplicationController
  skip_before_action :verify_authenticity_token, only: [:sign_out, :wechat_callback]
  before_action :no_login_required, only: [:sign_in, :sign_up]
  before_action :login_required, only: [:sign_out, :password, :profile]
  skip_before_action :no_login_required, only: [:check_login, :activation, :users_rank, :wechat_callback]
  skip_before_action :login_required, only: [:check_login, :activation, :users_rank, :wechat_callback]

  def sign_in
    if request.get?
      store_location params[:return_to]
    end

    if request.post?
      if params[:account].blank?
        flash[:error] = "请输入手机号或者邮箱登录"
        redirect_to :back
        return
      end

      @user = User.find_by(email: params[:account])
      @user ||= User.find_by(mobile: params[:account])

      if @user && @user.authenticate(params[:password])
        if @user.actived?
          login_as @user
          remember_me if params[:remember_me] == '1'
          redirect_back_or_default root_url
        else
          flash[:error] = "账号尚未激活，请检查注册邮件并激活账号"
          redirect_to :back
        end
      else
        flash[:error] = "错误的账号或者密码"
        redirect_to :back
      end
    end
  end

  def sign_up
    @user = User.new

    if request.post?
      @user = User.new(user_params)
      if @user.valid?(:email_regist)
        @user.state = :actived
        @user.save!

        flash[:info] = "注册成功，请登录"
        redirect_to sign_in_path

        # t = @user.g_active_token(@user.email)
        # UserMailer.delay(queue: 'mailing').activation_email(t)

        # flash[:info] = "已注册成功，请注意查收注册验证邮件"
        # redirect_to sign_in_path
      else
        render :sign_up
      end
    end
  end

  def send_email_code
    return if params[:email].blank?

    if User.find_by(email: params[:email])
      render json: { success: false, error: '这个邮箱已经被注册了' }
      return
    end

    begin
      ActiveToken.send_email_code(params[:email])
      render json: { success: true }
    rescue => e
      render json: { success: false, error: '出错了，请重试' }
    end
  end

  def wechat_callback
    @info = request.env["omniauth.auth"].extra.raw_info

    if @info.blank? or @info.openid.blank?
      flash[:error] = "授权失败，请联系客服"
      redirect_to :back
      return
    end

    if login?
      current_user.wx_openid = @info.openid
      current_user.wx_unionid = @info.unionid
      current_user.save
      redirect_back_or_default root_url 
    else
      @user = User.find_or_initialize_by(wx_openid: @info.openid)
      @user.wx_unionid = @info.unionid
      
      if !@user.persisted?
        @user.username = @info.nickname
      end

      if @user.mobile_binded?
        @user.save
        login_as(@user)
        redirect_back_or_default root_url
      else
        render :bind_mobile
      end
    end
  end

  def bind_mobile
    if request.post?
      @user = User.find_or_initialize_by(mobile: user_params[:mobile])

      if @user.persisted?
        User.where(wx_openid: user_params[:wx_openid]).update_all(wx_openid: nil, wx_unionid: nil)
      end

      @user.wx_openid = user_params[:wx_openid]
      @user.wx_unionid = user_params[:wx_unionid]
      @user.username = user_params[:username]
      @user.password = user_params[:password]
      @user.active_code = user_params[:active_code]
      @user.password_confirmation = user_params[:password]

      if !@user.persisted?
        @user.remote_avatar_url = params[:headimgurl]
      end

      if @user.valid?(:mobile_regist)
        @user.email = "__unbind__#{@user.mobile}@7234.cn"
        @user.state = :actived
        @user.save!

        login_as(@user)
        redirect_back_or_default root_url
      end
    end
  end

  def sign_up_mobile
    @user = User.new

    if request.post?
      @user = User.new(user_params)
      if @user.valid?(:mobile_regist)
        @user.email = "__unbind__#{@user.mobile}@7234.cn"
        @user.state = :actived
        @user.save!

        flash[:info] = "注册成功，请登录"
        redirect_to sign_in_path
      else
        render :sign_up_mobile
      end
    end
  end
  
  def send_active_code
    return if params[:mobile].blank?

    if params[:type] != "wx_auth" && User.find_by(mobile: params[:mobile])
      render json: { success: false, error: '这个手机号已经被注册了' }
      return
    end

    begin
      ActiveToken.send_active_code(params[:mobile])

      render json: { success: true }
    rescue => e
      render json: { success: false, error: '出错了，请重试' }
    end
  end

  def sign_out
    url = request.referer
    logout
    redirect_to url
  end

  def password
    if request.post?
      if current_user.authenticate(params[:password])
        current_user.password = params[:new_password]
        current_user.password_confirmation = params[:new_password_confirmation]
        if current_user.save(context: :reset_password)
          flash.now[:info] = "密码重置成功"
        else
          flash.now[:error] = current_user.errors.full_messages.first
        end
      else
        flash.now[:error] = "当前密码输入不正确"
      end
    end
  end

  def profile
    if request.post?
      current_user.avatar = params[:avatar]
      if current_user.save
        flash.now[:info] = "头像更新成功"
      else
        flash.now[:error] = current_user.errors.full_messages.first
      end
    end
  end

  def activation
    t = ActiveToken.check(params[:token])
    if t
      User.transaction do
        user = User.find_by!(email: t.receiver)
        user.actived!
        t.actived! 
        flash[:info] = "您的账号已激活，请登录"
      end
    else
      flash[:error] = "激活链接无效或已失效"
    end

    redirect_to sign_in_path
  end

  def check_login
    ret = params[:return_to].presence || ''
    return_to = if ret.include?('sign_up') or ret.include?('sign_in')
      nil
    else
      params[:return_to]
    end

    hongbao_html = nil

    if login?
      current_user.init_daily_credits! rescue nil

      if current_user.created_at >= '2018-02-11 00:00:00' && current_user.hongbaos.sign_up.count == 0
        token = Token.available(current_user).sample
        if token.present?
          hongbao = token.send_hongbao_to(current_user, 'sign_up')
          hongbao_html = render_to_string(partial: 'site/share/hongbao', locals: { hongbao: hongbao })
        end
      end
    end

    login_html = render_to_string(partial: 'site/welcome/login_state', locals: { return_to: return_to })
    post_box = render_to_string(partial: 'site/comments/post_box', locals: { return_to: return_to })
    render json: { login: login?, login_html: login_html, post_box: post_box, hongbao_html: hongbao_html }
  end

  def users_rank
    @users = User.order('credits DESC').limit(100)
  end

  private

  def user_params
    params.require(:user).permit(:email, :mobile, :active_code, :username, :password, :password_confirmation, :wx_openid, :wx_unionid)
  end
end

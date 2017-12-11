class Site::WelcomeController < Site::ApplicationController
  skip_before_action :verify_authenticity_token, only: [:sign_out]
  before_action :no_login_required, only: [:sign_in, :sign_up]
  before_action :login_required, only: [:sign_out, :password, :profile]
  skip_before_action :no_login_required, only: [:check_login, :activation]
  skip_before_action :login_required, only: [:check_login, :activation]

  def sign_in
    if request.get?
      store_location params[:return_to]
    end

    if request.post?
      @user = User.find_by(email: params[:email])
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
      if @user.valid?
        @user.save!

        flash[:info] = "已注册成功，请注意查收注册验证邮件"
        redirect_to sign_in_path
      else
        render :sign_up
      end
    end
  end

  def sign_up_mobile
    @user = User.new

    if request.post?
      @user = User.new(user_params)
      if @user.valid?
        @user.save!

        flash[:info] = "已注册成功，请注意查收注册验证邮件"
        redirect_to sign_in_path
      else
        render :sign_up_mobile
      end
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

    login_html = render_to_string(partial: 'site/welcome/login_state', locals: { return_to: return_to })
    post_box = render_to_string(partial: 'site/comments/post_box', locals: { return_to: return_to })
    render json: { login: login?, login_html: login_html, post_box: post_box }
  end

  private

  def user_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation)
  end
end

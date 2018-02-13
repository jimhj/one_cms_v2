class Mobile::ApplicationController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:sign_out]

  layout 'tt_mobile'
  
  # layout 'mobile'

  # self.page_cache_directory = Rails.root.join('public/page_cache/mobile').to_s

  # caches_action :index, :cache_path => Proc.new { |c| c.request.url + '-mobile-index' }, :expires_in => 2.hours

  # caches_action :index, cache_path: Proc.new { |c| 
  #   c.request.url + '-mobile-index' 
  # }, if: Proc.new {
  #   controller_name == 'application'
  # }, :expires_in => 2.hours

  # self.page_cache_directory = -> { Rails.root.join("public", 'mobile_cached_pages') }
  # caches_page :index

  caches_action :index, 
                :cache_path => Proc.new { |c| c.request.url + '-mobile-index' }, 
                :expires_in => 10.minutes, 
                :unless => -> { request.format.json? or request.fullpath.include?('hongbaos') }

  caches_action :column, 
                :cache_path => Proc.new { |c| c.request.url + '-mobile-index' }, 
                :expires_in => 10.minutes, 
                :unless => -> { request.format.json? }

  def index
    @articles = Article.recommend(page: params[:page])
    @focus = Article.focus
    @miphtml = "#{Setting.mobile_domain}/mip/"
    # @links = Link.where(linkable_id: 0).mobile
  end

  def column
    @nodes = Node.where(is_column: true, is_at_top: true).order('sortrank DESC')
    @articles = Article.where(node_id: @nodes.pluck(:id))
                       .where(approved: true).order('id DESC')
                       .paginate(page: params[:page], per_page: 20, total_entries: 10000)
    @miphtml = "#{Setting.mobile_domain}/mip/"

    render template: 'mobile/application/index'
  end

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
      raise e
      render json: { success: false, error: '出错了，请重试' }
    end
  end
  
  def send_active_code
    return if params[:mobile].blank?

    if User.find_by(mobile: params[:mobile])
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

  def check_login
    ret = params[:return_to].presence || ''
    return_to = if ret.include?('sign_up') or ret.include?('sign_in')
      nil
    else
      params[:return_to]
    end

    # current_user.init_daily_credits! if login?

    hongbao_html = nil
    if login?
      current_user.init_daily_credits!

      if current_user.created_at >= '2018-02-11 00:00:00' && current_user.hongbaos.sign_up.count == 0
        token = Token.available(current_user).sample
        if token.present?
          hongbao = token.send_hongbao_to(current_user, 'sign_up')
          hongbao_html = render_to_string(partial: 'site/share/hongbao', locals: { hongbao: hongbao })
        end
      end
    end

    login_html = render_to_string(partial: 'mobile/application/login_state', locals: { return_to: return_to })
    post_box = render_to_string(partial: 'mobile/comments/post_box', locals: { return_to: return_to })
    render json: { login: login?, login_html: login_html, post_box: post_box, hongbao_html: hongbao_html }
  end

  private

  def user_params
    params.require(:user).permit(:email, :mobile, :active_code, :username, :password, :password_confirmation)
  end
end
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :login?, :current_user

  def login_required
    unless login?
      flash[:error] = "请登录后访问"
      options =  { 
        :protocol   => 'http://', 
        :controller => 'site/welcome', 
        :action     => 'sign_in'  
      }

      options.merge!(return_to: request.fullpath) if request.get?
      options.merge!(protocol: 'https://') if Rails.env.production?
        
      redirect_to options
    end
  end

  def no_login_required
    if login?
      redirect_to root_url
    end
  end

  def current_user
    @current_user ||= login_from_session || login_from_cookies unless defined?(@current_user)
    @current_user
  end

  def login?
    !!current_user
  end

  def login_as(user)
    session[:user_id] = user.id
    @current_user = user
    track_user
  end

  def logout
    session.delete(:user_id)
    @current_user = nil
    forget_me
  end

  def login_from_session
    if session[:user_id].present?
      begin
        User.find session[:user_id]
      rescue
        session[:user_id] = nil
      end
    end
  end

  def login_from_cookies
    if cookies[:remember_token].present?
      if user = User.find_by_remember_token(cookies[:remember_token])
        session[:user_id] = user.id
        user
      else
        forget_me
        nil
      end
    end
  end

  def store_location(path)
    session[:return_to] = path
  end

  def redirect_back_or_default(default)
    redirect_to(session.delete(:return_to) || default)
  end

  def forget_me
    cookies.delete(:remember_token)
  end

  def remember_me
    cookies[:remember_token] = {
      value: current_user.remember_token,
      expires: 2.weeks.from_now,
      httponly: true
    }
  end

  def track_user
    current_user.update_columns(
      sign_in_count:      current_user.sign_in_count + 1,
      current_sign_in_at: Time.now,
      last_sign_in_at:    current_user.current_sign_in_at,
      current_sign_in_ip: request.remote_ip,
      last_sign_in_ip:    current_user.current_sign_in_ip
    )
  end

  def robots
    render :text => "Sitemap:http://#{SiteConfig.actived.domain}/sitemap.xml\nUser-agent: *\nDisallow:/*?*"
  end

  def dasai
    render layout: false
  end

  private

  def set_meta(tags)
    tags = tags.delete_if { |name, value| value.blank? }
    set_meta_tags tags
  end
end

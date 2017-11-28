class Site::WelcomeController < Site::ApplicationController
  before_action :no_login_required, only: [:sign_in, :sign_up]
  before_action :login_required, only: [:sign_out]

  def sign_in
    if request.post?
      @user = User.find_by(email: params[:email])
      if @user && @user.authenticate(params[:password])
        login_as @user
        remember_me if params[:remember_me] == '1'
        redirect_back_or_default root_url
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

  def sign_out
    logout
    redirect_to root_url
  end

  private

  def user_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation)
  end
end

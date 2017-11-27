class Site::WelcomeController < Site::ApplicationController
  before_action :no_login_required, only: [:sign_in, :sign_up]
  before_action :login_required, only: [:sign_out]

  def sign_in
  end

  def sign_up
    @user = User.new

    if request.post?
      @user = User.new(user_params)
      if @user.valid?
      else
        render :sign_up
      end
    end
  end

  def sign_out
  end

  private

  def user_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation)
  end
end

class Admin::UsersController < Admin::ApplicationController
  before_action :find_user, only: [:edit, :update]

  def index
    @users = User.order('id DESC').paginate(paginate_params)
  end

  def edit
  end

  def update
    @user.allowed_node_ids = (params[:allowed_node_ids].presence || []).join('|')
    if @user.update_attributes(user_params)
      redirect_to admin_users_path
    else
      render :edit
    end
  end

  private

  def find_user
    @user = User.find params[:id]
  end

  def user_params
    params.require(:user).permit(:username, :email, :state, :review_later)
  end

  def paginate_params
    { page: params[:page], per_page: 40 }
  end  
end
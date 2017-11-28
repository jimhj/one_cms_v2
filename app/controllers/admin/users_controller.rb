class Admin::UsersController < Admin::ApplicationController
  def index
    @users = User.order('id DESC').paginate(paginate_params)
  end

  private

  def find_user
    @user = User.find params[:id]
  end

  def link_params
    params.require(:link).permit(:name, :url, :title, :qq, :sortrank, :device, :linkable_type, :linkable_id)
  end

  def paginate_params
    { page: params[:page], per_page: 40 }
  end  
end
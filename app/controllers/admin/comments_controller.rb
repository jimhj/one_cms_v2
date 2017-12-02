class Admin::CommentsController < Admin::ApplicationController
  def index
    @comments = Comment.includes(:user, :article)
      .order('id DESC')
      .paginate(paginate_params)
  end

  def show
  end

  def destroy
    @comment = Comment.find params[:id]
    @comment.destroy

    redirect_to :back
  end

  private

  def paginate_params
    { page: params[:page], per_page: 40 }
  end  
end
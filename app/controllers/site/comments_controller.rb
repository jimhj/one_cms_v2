class Site::CommentsController < Site::ApplicationController
  before_action :login_required, except: [:index]
  before_action :find_article

  def index
    @comments = @article.comments.where(approved: true).order('id DESC')
    html = render_to_string(partial: 'site/comments/comment_list', locals: { comments: @comments })
    render json: { html: html }
  end

  def create
    @comment = @article.comments.build
    @comment.user = current_user
    @comment.content = params[:content]

    if @comment.save
      html = render_to_string(partial: 'site/comments/comment', locals: { comment: @comment })
      ret = { success: true, html: html }
    else
      ret = { success: false, error: @comment.errors.full_messages.first }
    end

    render json: ret
  end

  private

  def find_article
    @article = Article.find params[:article_id]
  end
end
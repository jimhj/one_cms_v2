class Mobile::CommentsController < Mobile::ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :login_required, except: [:index]
  before_action :find_article

  def index
    @comments = @article.comments.includes(:user, :reply_user, :reply_comment).where(approved: true).order('id ASC')
    html = render_to_string(partial: 'mobile/comments/comment_list', locals: { comments: @comments })
    hits = @article.incr_hits
    render json: { html: html, hits: @article.hits, count: @comments.count }
  end

  def create
    if not current_user.can_comment?
      render json: { success: false, error: '您评论的频率太快了，休息一下吧！' }
      return 
    end

    @comment = @article.comments.build
    @comment.user = current_user
    @comment.to_user_id = params[:to_user_id]
    @comment.reply_to_id = params[:reply_to_id]
    @comment.content = params[:content]

    begin
      if @comment.save
        html = render_to_string(partial: 'mobile/comments/comment', locals: { comment: @comment })
        ret = { success: true, html: html }
      else
        ret = { success: false, error: @comment.errors.full_messages.first }
      end

      render json: ret
    rescue ActiveRecord::StatementInvalid => e
      render json: { success: false, error: '暂不支持表情符号等特殊符号评论' }
    end 
  end

  private

  def find_article
    @article = Article.find params[:article_id]
  end
end
class Mobile::HongbaosController < Mobile::ApplicationController
  before_action :login_required
  
  def index
    @hongbaos = current_user.hongbaos.order('id DESC').paginate(page: params[:page], per_page: 20)
  end

  def tokens
    @tokens = current_user.tokens.order('id DESC').paginate(page: params[:page], per_page: 20)
  end

  def create
    if params[:from] == 'sign_up' && current_user.hongbaos.sign_up.count >= 1
      render json: { available: false }
      return
    end

    if params[:from] == 'comment' && current_user.hongbaos.comment.today.count >= 3
      render json: { available: false }
      return
    end

    token = Token.available(current_user).sample
    if token.nil?
      render json: { available: false }
      return
    end

    if ['comment', 'sign_up'].include?(params[:from])
      hongbao = token.send_hongbao_to(current_user, params[:from])
      html = render_to_string(partial: 'site/share/hongbao', locals: { hongbao: hongbao }) 
      render json: { html: html, available: true }
    end
  end

  def open
    hongbao = current_user.hongbaos.find params[:hongbao_id]
    if hongbao.opened?
      render json: { success: false, error: '此红包已打开，请至个人中心-我的红包查看' }
    else
      hongbao.open!
      render json: { success: true, amount: "#{hongbao.amount} #{hongbao.token.code}" }
    end
  end

  def withdraws
    @withdraws = current_user.token_withdraws.order('id DESC').paginate(page: params[:page], per_page: 20)
  end

  def new_withdraw
    @user_token = current_user.tokens.find params[:user_token_id]

    if request.post?

      if params[:amount].to_f == 0
        flash[:alert] = "提现金额必须大于0"
        render
        return
      end

      if params[:amount].to_f > @user_token.amount.to_f
        flash[:alert] = "超出了最大提现金额"
        render
        return
      end

      TokenWithdraw.transaction {
        @withdraw = @user_token.token_withdraws.build
        @withdraw.address = params[:address]
        @withdraw.amount = params[:amount]
        @withdraw.user_token_snapshot = @user_token.as_json
        @user_token.amount = @user_token.amount - @withdraw.amount
        @user_token.save!
        @withdraw.save!
      
        redirect_to withdraws_hongbaos_path
      }
    end
  end
end

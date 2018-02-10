class Admin::TokensController < Admin::ApplicationController
  before_action :find_token, only: [:edit, :update, :destroy]

  def index
    @tokens = Token.order('id DESC')
  end

  def new
    @token = Token.new
  end

  def create
    @token = Token.new(token_params)

    if @token.save
      redirect_to admin_tokens_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @token.update_attributes(token_params)
      redirect_to admin_tokens_path
    else
      render action: :edit
    end
  end

  def hongbaos
    @hongbaos = TokenHongbao.order('id DESC').paginate(page: params[:page], per_page: 40)
  end

  def withdraws
    @withdraws = TokenWithdraw.order('id DESC')

    if params[:state] == 'pending'
      @withdraws = @withdraws.pending
    elsif params[:state] == 'processing'
      @withdraws = @withdraws.processing
    elsif params[:state] == 'completed'
      @withdraws = @withdraws.completed
    end

    @withdraws = @withdraws.paginate(page: params[:page], per_page: 40)
  end

  def handle_withdraw
    withdraw = TokenWithdraw.find params[:withdraw_id]
    if TokenWithdraw.state_mapping.keys.include?(params[:state])
      withdraw.state = params[:state]
      withdraw.save!
    end

    render nothing: true
  end

  private

  def find_token
    @token = Token.find params[:id]
  end

  def token_params
    params.require(:token).permit!
  end
end
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
  end

  private

  def find_token
    @token = Token.find params[:id]
  end

  def token_params
    params.require(:token).permit!
  end
end
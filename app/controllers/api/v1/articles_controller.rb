class Api::V1::ArticlesController < Api::V1::ApplicationController
  def index
    nodes = Node.all.select{ |node| node.api_node.to_i == 1 }.map(&:id)

    per_page = (params[:per_page].presence || 20).to_i
    per_page = 100 if per_page > 100
    
    @articles = if params[:category_id].blank?
      []
    elsif !nodes.include?(params[:category_id].to_i)
      []
    else
      Article.where(approved: true).order('id DESC').paginate(page: params[:page], per_page: per_page)
    end
  end
end
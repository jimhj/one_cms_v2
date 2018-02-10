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
      node = Node.find_by(id: params[:category_id])
      return [] if node.blank?

      @articles = Article.where(node_id: node.self_and_descendants.pluck(:id))
                       .where(approved: true)
                       .order('id DESC')
                       .paginate(page: params[:page], per_page: 20, total_entries: 1000000)

    end
  end
end
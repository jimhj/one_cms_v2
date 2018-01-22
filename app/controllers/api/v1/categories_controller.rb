class Api::V1::CategoriesController < Api::V1::ApplicationController
  def index
    @categories = Node.all.select{ |node| node.api_node.to_i == 1 }.collect do |cate|
      {
        category_id: cate.id,
        name: cate.name,
        short_name: cate.short_name,
        articles: "https://www.7234.cn/api/v1/category/#{cate.id}/page/1"
      }
    end

    render json: @categories
  end
end
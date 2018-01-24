class Api::V1::CategoriesController < Api::V1::ApplicationController
  def index
    @categories = Node.all.select{ |node| node.api_node.to_i == 1 }.collect do |cate|
      node = cate_to_hash(cate)
      children = cate.children.collect { |child| cate_to_hash(child) }
      node.merge(children: children)
    end

    render json: @categories
  end

  private

  def cate_to_hash(cate)
    {
      category_id: cate.id,
      name: cate.name,
      short_name: cate.short_name,
      articles: "https://www.7234.cn/api/v1/category/#{cate.id}/page/1"
    }
  end
end
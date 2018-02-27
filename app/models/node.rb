class Node < ActiveRecord::Base
  acts_as_nested_set :counter_cache => :children_count

  has_many :articles, dependent: :destroy
  has_many :links, as: :linkable, dependent: :destroy

  validates_presence_of :name, :slug
  validates_uniqueness_of :slug

  store :extras, accessors: [
    :customize_section_top,
    :api_node
  ]

  mount_uploader :logo, LogoUploader

  def self.rest
    roots.where(is_nav: false)
  end

  def short_name
    nav_name.presence || name
  end

  # for navigation
  def nav_nodes(current_slug = nil)
    node = self
    node = self.parent if node.children.blank?

    return [] if node.nil?

    child_nodes = node.children

    if current_slug.present?
      current_node = child_nodes.find_by(slug: current_slug)
      child_nodes = child_nodes.where.not(slug: current_slug)
    else
      current_node = nil
    end

    child_nodes = child_nodes.where(is_shown: true).except(:order).order('sortrank DESC')
    [current_node, child_nodes].compact.flatten
  end
end

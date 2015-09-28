class Category < ActiveRecord::Base
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################
  acts_as_nested_set counter_cache: :children_count
  attr_protected :lft, :rgt

  ### Associations #################################################################################
  has_many :inventory_items
  has_one :image, as: :imageable
  has_and_belongs_to_many :stores

  accepts_nested_attributes_for :image

  ### Callbacks ####################################################################################

  ### Validations ##################################################################################
  validates :name, presence: true

  ### Scopes #######################################################################################

  ### Other ########################################################################################


  ### Class Methods ################################################################################
  def self.get_store_categories(store_id)
    res = []
    Store.find(store_id).categories.where(parent_id: nil).order(:name).each do |c|
      x = c.as_json
      x[:children] = c.get_children(store_id)
      res << x
    end
    return res
  end


  ### Instance Methods #############################################################################
  def get_info(store_id)
    res = self.as_json
    res[:children] = self.get_children(store_id)
    res
  end

  def get_children(store_id)
    res = []
    return res if self.children_count == 0
    Store.find(store_id).categories.where(parent_id: id).order(:name).each_with_index do |c, i|
      res[i] = c.as_json
      res[i][:children] = c.get_children(store_id)
    end
    res
  end

  private


end

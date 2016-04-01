class Category < ActiveRecord::Base
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################
  acts_as_nested_set counter_cache: :children_count
  attr_protected :lft, :rgt
  has_paper_trail

  ### Associations #################################################################################
  has_many :inventory_items
  has_many :med_batches
  has_one :image, as: :imageable
  has_and_belongs_to_many :stores

  accepts_nested_attributes_for :image

  ### Callbacks ####################################################################################

  ### Validations ##################################################################################
  validates :name, presence: true

  ### Scopes #######################################################################################
  scope :base_level, -> { where(parent_id: nil) }
  scope :last_level, -> { where('parent_id IS NOT ? and children_count = ?', nil, 0)}

  ### Other ########################################################################################


  ### Class Methods ################################################################################
  def self.get_store_categories(store_id)
    res = []
    Store.find(store_id).categories.where(parent_id: nil).order(:name).each do |c|
      x = c.as_json(methods: :photo_thumb)
      x[:children] = c.get_children(store_id)
      res << x
    end
    return res
  end


  ### Instance Methods #############################################################################
  def photo_thumb
    {id: self.image.id, photo: self.image.photo.url(:thumb), processed: self.image.processed} if self.image
  end

  def get_info(store_id)
    res = self.as_json(methods: :photo_thumb)
    res[:children] = self.get_children(store_id)
    res
  end

  def get_children(store_id)
    res = []
    return res if self.children_count == 0
    Store.find(store_id).categories.where(parent_id: id).order(:name).each_with_index do |c, i|
      res[i] = c.as_json(methods: :photo_thumb)
      res[i][:children] = c.get_children(store_id)
    end
    res
  end

  private


end

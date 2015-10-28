class InventoryItem < ActiveRecord::Base
  ### Attributes ###################################################################################
  enum status: [:active, :inactive]

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################
  belongs_to :store
  belongs_to :category
  belongs_to :itemable, polymorphic: true
  has_many :med_batches, dependent: :destroy  # Production batches for itemable
  has_one  :sale_price, class_name: Price, as: :priceable     # Smallest unit price
  has_many :sales, class_name: Transaction, foreign_key: :seller_item_id, dependent: :destroy
  has_many :purchases, class_name: Transaction, foreign_key: :buyer_item_id, dependent: :destroy
  has_many :adjustments, class_name: Transaction, foreign_key: :adjust_item_id, dependent: :destroy
  has_one :image, as: :imageable, dependent: :destroy

  accepts_nested_attributes_for :med_batches
  accepts_nested_attributes_for :sale_price

  ### Callbacks ####################################################################################
  after_create :set_default_image

  ### Validations ##################################################################################


  ### Scopes #######################################################################################
  scope :active, -> { where(status: 0) }
  scope :inactive, -> { where(status: 1) }
  scope :by_category, -> (cat_id) { where(category_id: cat_id)}

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################
  def photo_thumb
    self.image.photo.url(:thumb) if self.image
  end

  private
  def set_default_image
    if self.image.nil? and !self.itemable.nil? and !self.itemable.image.nil?
      self.create_image(photo: self.itemable.image.photo)
    end
  end

end

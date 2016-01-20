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
  has_many :available_batches, -> {where('total_units > 0')}, class_name: MedBatch
  has_many :good_batches, -> {where('expire_date > ?', Date.today)}, class_name: MedBatch
  has_many :empty_batches, -> {where('total_units <= 0')}, class_name: MedBatch
  has_one  :sale_price, class_name: Price, as: :priceable     # Smallest unit price
  has_many :sales, class_name: Transaction, foreign_key: :seller_item_id, dependent: :destroy
  has_many :purchases, class_name: Transaction, foreign_key: :buyer_item_id, dependent: :destroy
  has_many :adjustments, class_name: Transaction, foreign_key: :adjust_item_id, dependent: :destroy
  has_one :image, as: :imageable, dependent: :destroy

  accepts_nested_attributes_for :med_batches
  accepts_nested_attributes_for :sale_price
  accepts_nested_attributes_for :image

  ### Callbacks ####################################################################################
  after_create :set_default_image

  ### Validations ##################################################################################
  # We are deliberately not validate amount to be greater than or equal to zero to make sure any sale is recorded
  # We will use business logic to address negative amount in inventory

  ### Scopes #######################################################################################
  scope :active, -> { where(status: 0) }
  scope :inactive, -> { where(status: 1) }
  scope :by_category, -> (cat_id) { where(category_id: cat_id)}
  scope :by_type, ->(type) { joins("JOIN #{type.table_name} ON #{type.table_name}.id = #{InventoryItem.table_name}.itemable_id AND #{InventoryItem.table_name}.itemable_type = '#{type.to_s}'") }

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################
  def photo_thumb
    {id: self.image.id, photo: self.image.photo.url(:thumb), processed: self.image.processed} if self.image
  end

  private
  def set_default_image
    if self.image.nil? and !self.itemable.nil? and !self.itemable.image.nil?
      self.create_image(photo: self.itemable.image.photo)
    end
  end

end

class InventoryItem < ActiveRecord::Base
  ### Attributes ###################################################################################
  enum status: [:active, :inactive]

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################
  has_paper_trail

  ### Associations #################################################################################
  belongs_to :store
  belongs_to :category
  belongs_to :itemable, polymorphic: true
  has_many :med_batches, dependent: :destroy  # Production batches for itemable
  has_many :available_batches, -> { active.where('total_units > 0')}, class_name: MedBatch
  has_many :good_batches, -> {where('expire_date > ?', Date.today)}, class_name: MedBatch
  has_many :empty_batches, -> {where('total_units <= 0')}, class_name: MedBatch
  has_one  :sale_price, class_name: Price, as: :priceable, dependent: :destroy     # Smallest unit price
  has_many :sale_transactions, dependent: :destroy
  has_many :purchase_transactions, dependent: :destroy
  has_many :adjustment_transactions, dependent: :destroy
  has_one :image, as: :imageable, dependent: :destroy

  accepts_nested_attributes_for :med_batches
  accepts_nested_attributes_for :sale_price
  accepts_nested_attributes_for :image

  ### Callbacks ####################################################################################
  after_create :set_item_name

  ### Validations ##################################################################################
  # We are deliberately not validate amount to be greater than or equal to zero to make sure any sale is recorded
  # We will use business logic to address negative amount in inventory

  ### Scopes #######################################################################################
  scope :active, -> { where(status: 0) }
  scope :inactive, -> { where(status: 1) }
  scope :by_category, -> (cat_id) { where(category_id: cat_id)}
  scope :by_type, ->(type) { joins("JOIN #{type.table_name} ON #{type.table_name}.id = #{InventoryItem.table_name}.itemable_id AND #{InventoryItem.table_name}.itemable_type = '#{type.to_s}'") }
  scope :by_medicine_name, ->(name) { by_type(Medicine).where('medicines.name LIKE ?', "%#{name.titleize}%") }
  scope :without_sale_price, -> {
    zero_ids = Price.where('priceable_type = ? AND amount > ?', 'InventoryItem', 0).map(&:priceable_id).uniq
    InventoryItem.where.not(id:  zero_ids)
  }
  scope :out_of_stock, -> {where(amount: 0)}

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################
  def photo_thumb
    if self.image
      {id: self.image.id, photo: self.image.photo_thumb, processed: self.image.processed}
    elsif itemable
      self.itemable.photo_thumb
    end
  end

  def photo_medium
    if self.image
      {id: self.image.id, photo: self.image.photo_medium, processed: self.image.processed}
    elsif itemable
      self.itemable.photo_medium
    end
  end

  private
  def set_item_name
    if itemable and itemable_type == 'Medicine' and self.item_name.blank?
      self.update!(item_name: Medicine.find(itemable_id).name)
    end
  end

end

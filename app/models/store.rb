class Store < ActiveRecord::Base
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################
  has_paper_trail

  ### Associations #################################################################################
  belongs_to :company
  has_many   :employees, class_name: User
  has_one :location, as: :locationable, dependent: :destroy
  has_one :image, as: :imageable, dependent: :destroy
  has_many :documents, as: :documentable, dependent: :destroy
  has_many :inventory_items, dependent: :destroy, counter_cache: true, foreign_key: :store_id
  has_many :medicines, through: :inventory_items, source: :itemable, source_type: 'Medicine'
  has_many :med_batches, dependent: :destroy
  has_and_belongs_to_many :categories
  has_many :receipts, dependent: :destroy
  has_many :purchases, class_name: Transaction, foreign_key: :buyer_id
  has_many :sales, class_name: Transaction, foreign_key: :seller_id
  has_many :adjustments, class_name:  Transaction, foreign_key: :adjust_store_id

  ### Callbacks ####################################################################################

  ### Validations ##################################################################################
  validates :name, presence: true

  ### Scopes #######################################################################################

  ### Other ########################################################################################
  accepts_nested_attributes_for :location, allow_destroy: :true
  accepts_nested_attributes_for :image, allow_destroy: :true
  accepts_nested_attributes_for :documents, allow_destroy: :true

  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################
  def photo_thumb
    {id: self.image.id, photo: self.image.photo.url(:thumb), processed: self.image.processed} if self.image
  end

  private


end

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

  accepts_nested_attributes_for :med_batches
  accepts_nested_attributes_for :sales
  accepts_nested_attributes_for :purchases

  ### Callbacks ####################################################################################

  ### Validations ##################################################################################


  ### Scopes #######################################################################################

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################

  private
end

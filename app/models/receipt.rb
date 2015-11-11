class Receipt < ActiveRecord::Base
  ### Attributes ###################################################################################
  enum receipt_type: ['purchase', 'sale', 'adjustment']
  # Column total store the total money amount for the receipt

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################
  belongs_to :store
  has_many :transactions

  accepts_nested_attributes_for :transactions

  ### Callbacks ####################################################################################
  #TODO: Need callbacks to handle negative amount in inventory
  #TODO: Need callbacks to handle total price != sum of sale price

  ### Validations ##################################################################################


  ### Scopes #######################################################################################
  scope :purchase_receipts, -> { where(receipt_type: 0) }
  scope :sale_receipts, -> { where(receipt_type: 1) }
  scope :adjustment_receipts, -> { where(receipt_type: 2)}
  scope :created_before, ->(date) {where('created_at < ?', date)}
  scope :created_after, ->(date) {where('created_at >= ?', date)}


  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################


  private
end

class Receipt < ActiveRecord::Base
  ### Attributes ###################################################################################
  enum receipt_type: ['purchase', 'sale', 'adjustment']
  # Column total store the total money amount for the receipt

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################
  include RandomGenerable
  has_paper_trail

  ### Associations #################################################################################
  belongs_to :store
  has_many :transactions
  has_many :med_batches

  has_many :purchase_transactions
  has_many :sale_transactions
  has_many :adjustment_transactions

  accepts_nested_attributes_for :med_batches
  accepts_nested_attributes_for :purchase_transactions
  accepts_nested_attributes_for :sale_transactions
  accepts_nested_attributes_for :adjustment_transactions

  ### Callbacks ####################################################################################
  after_save :calculate_total
  before_create :generate_barcode


  ### Validations ##################################################################################


  ### Scopes #######################################################################################
  scope :purchase_receipts, -> { where(receipt_type: 0) }
  scope :sale_receipts, -> { where(receipt_type: 1) }
  scope :adjustment_receipts, -> { where(receipt_type: 2)}
  scope :created_max, ->(date) {where('created_at <= ?', date)}
  scope :created_min, ->(date) {where('created_at >= ?', date)}


  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################

  private
  def calculate_total
    # Must not update total price of adjustment receipt. Will create infinite loop
    # Adjustment transaction will update the total price once they are created successfully
    if receipt_type != 'adjustment' and total.blank?
      self.update!(total: self.transactions.sum(:total_price)) if total.blank?
    end
  end

  def generate_barcode
    self.barcode = Receipt.barcode_generate
  end

end

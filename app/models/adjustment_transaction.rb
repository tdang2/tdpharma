class AdjustmentTransaction < Transaction
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################

  ### Callbacks ####################################################################################
  before_save  :set_transaction_type
  before_save  :process_adjustment
  after_create :update_adjustment

  ### Validations ##################################################################################

  ### Scopes #######################################################################################

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################

  private
  def set_transaction_type
    self.transaction_type = 'adjustment'
  end

  def process_adjustment
    self.amount = new_total - inventory_item.amount
    self.total_price = (new_total - inventory_item.amount) * inventory_item.sale_price.amount if inventory_item.sale_price
  end

  def update_adjustment
    # TODO: rethink how to update inventory count while keeping track of which batch is missing
    if inventory_item.sale_price
      # must check for sale price existence because that is a condition to update a new total price
      receipt_value = self.total_price
      if self.receipt and self.receipt.total
        receipt_value = self.receipt.total + self.total_price
      end
      self.receipt.update!(total: receipt_value)
    end
    self.inventory_item.update!(amount: self.new_total)
  end

end
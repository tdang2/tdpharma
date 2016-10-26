class SaleTransaction < Transaction
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################

  ### Callbacks ####################################################################################
  before_save  :set_transaction_type
  after_create :process_sale
  after_update :edit_inventories

  ### Validations ##################################################################################

  ### Scopes #######################################################################################

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################

  private

  def set_transaction_type
    self.transaction_type = 'sale'
  end

  def edit_inventories
    # Callback to correct users' mistakes. This is not the process to reconcile mismatch inventory count
    receipt_price_diff = total_price
    if status_changed? and status == 'deprecated'
      reverse_sale    # Cancel / Customer return
      receipt_price_diff = 0
    else
      if med_batch_id_changed?
        # Update with a different med_batch. Expect to receive both new batch_id and item_id.
        reverse_sale  # First correct the old med_batch and inventories
        process_sale  # Then process the new batch and inventory item
      else
        edit_sale     # Update with the same med_batch
      end
    end
    self.receipt.update!(total: self.receipt.total - total_price_was + receipt_price_diff) if (total_price_changed? or receipt_price_diff === 0) and receipt
  end

  def process_sale
    # Also update med_batch to reflect remaining quantity. Must use 'reload' on inventory item in case the data is not updated in the same thread
    self.inventory_item.update!(amount: self.inventory_item.reload.amount - self.amount)
    self.med_batch.update!(total_units: self.med_batch.total_units - self.amount) if self.med_batch
  end
  handle_asynchronously :process_sale

  def reverse_sale
    ob = MedBatch.find(med_batch_id_was)
    if ob
      ob.update!(total_units: ob.total_units + amount_was)
      ob.inventory_item.update!(amount: ob.inventory_item.amount + amount_was) if ob.inventory_item
    end
  end
  handle_asynchronously :reverse_sale

  def edit_sale
    seller_item_params = {}
    med_batch.update!(total_units: med_batch.total_units + amount_was - amount) if med_batch and amount_changed?
    seller_item_params = seller_item_params.merge({amount: inventory_item.amount + amount_was - amount}) if amount_changed?
    inventory_item.update!(seller_item_params) unless seller_item_params.blank?
  end
  handle_asynchronously :edit_sale


end
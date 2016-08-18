class PurchaseTransaction < Transaction
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################

  ### Callbacks ####################################################################################
  before_save  :set_transaction_type
  after_create :update_purchases
  after_update :edit_purchases

  ### Validations ##################################################################################

  ### Scopes #######################################################################################

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################

  private
  def set_transaction_type
    self.transaction_type = 'PurchaseTransaction'
  end

  def update_purchases
    # After a transaction, update respective inventories and med_batches
    self.inventory_item.update!(amount: self.inventory_item.amount + self.amount,
                            avg_purchase_price: self.inventory_item.purchase_transactions.active.average(:total_price),
                            avg_purchase_amount: self.inventory_item.purchase_transactions.active.average(:amount))
  end


  def edit_purchases
    # Callback to correct users' mistakes. This is not the process to reconcile mismatch inventory count
    receipt_price_diff = total_price
    if status_changed? and self.status == 'deprecated'
      reverse_purchase # Cancel the purchase transaction
      receipt_price_diff = 0
    else
      edit_purchase    # Correct the purchase transaction
    end
    self.receipt.update!(total: self.receipt.total - total_price_was + receipt_price_diff) if (total_price_changed? or receipt_price_diff === 0) and self.receipt
  end


  def reverse_purchase
    inventory_item.update!(amount: self.inventory_item.amount - amount_was, avg_purchase_amount: self.inventory_item.purchase_transactions.active.average(:amount))
    self.med_batch.update!(user_id: self.user_id, status: 1) if self.med_batch # deprecate the new purchase med_batch
  end

  def edit_purchase
    if amount_changed?
      self.inventory_item.update!(amount: inventory_item.amount - amount_was + amount, avg_purchase_amount: self.inventory_item.purchase_transactions.active.average(:amount))
    end
    if med_batch and amount_changed?
      batch_params = {total_units: amount, user_id: user_id}
      batch_params = batch_params.merge!(total_price: total_price) if total_price_changed?
      batch_params = batch_params.merge!(paid: paid) if paid_changed?
      self.med_batch.update!(batch_params)
    end
    self.inventory_item.update!(avg_purchase_price: self.inventory_item.purchase_transactions.active.average(:total_price)) if total_price_changed?
  end




end
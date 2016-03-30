class Transaction < ActiveRecord::Base
  ### Attributes ###################################################################################
  enum transaction_type: ['activity', 'adjustment']

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################
  belongs_to :buyer, class_name: Store, foreign_key: :buyer_id
  belongs_to :seller, class_name: Store, foreign_key: :seller_id
  belongs_to :adjust_store, class_name: Store, foreign_key: :adjust_store_id
  belongs_to :seller_item, class_name: InventoryItem, foreign_key: :seller_item_id
  belongs_to :buyer_item, class_name: InventoryItem, foreign_key: :buyer_item_id
  belongs_to :adjust_item, class_name: InventoryItem, foreign_key: :adjust_item_id
  belongs_to :sale_user, class_name: User, foreign_key: :sale_user_id
  belongs_to :purchase_user, class_name: User, foreign_key: :purchase_user_id
  belongs_to :adjust_user, class_name: User, foreign_key: :adjust_user_id
  belongs_to :receipt
  belongs_to :med_batch


  ### Callbacks ####################################################################################
  after_create :update_inventories
  after_update :edit_inventories

  ### Validations ##################################################################################
  # A store can sell to patients which does not have a buyer_id and buyer_item_id
  validates :due_date, :delivery_time, presence: true
  validate :author_existence, :item_existence, :value_existence
  validate :note_existence


  ### Scopes #######################################################################################

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################


  private
  def edit_inventories
    # Callback to correct users' mistakes. This is not the process to reconcile mismatch inventory count
    if receipt and receipt.receipt_type == 'purchase' and buyer_item
      if amount_changed?
        self.buyer_item.update!(amount: buyer_item.amount - amount_was + amount, avg_purchase_amount: self.buyer_item.purchases.average(:amount))
        self.med_batch.update!(total_units: amount) if self.med_batch
      end
      self.med_batch.update!(total_price: total_price) if total_price_changed? and med_batch
      self.buyer_item.update!(avg_purchase_price: self.buyer_item.purchases.average(:total_price)) if total_price_changed?
    elsif receipt and receipt.receipt_type == 'sale' and seller_item
      if amount_changed?
        self.seller_item.update!(amount: seller_item.amount + amount_was - amount, avg_sale_amount: self.seller_item.sales.average(:amount))
        self.med_batch.update!(total_units: self.med_batch.total_units + amount_was - amount) if self.med_batch
      end
      self.seller_item.update!(avg_sale_price: self.seller_item.sales.average(:total_price)) if total_price_changed?
    end
    self.receipt.update!(total: self.receipt.total - total_price_was + total_price) if total_price_changed? and receipt
  end


  def update_inventories
    # After a transaction, update respective inventories and med_batches
    if self.receipt and self.receipt.receipt_type == 'purchase' and buyer_item
      self.transaction_type = 'activity'
      self.buyer_item.update!(amount: self.buyer_item.amount + self.amount,
                        avg_purchase_price: self.buyer_item.purchases.average(:total_price),
                        avg_purchase_amount: self.buyer_item.purchases.average(:amount))
    elsif self.receipt and self.receipt.receipt_type == 'sale' and seller_item
      self.transaction_type = 'activity'
      self.seller_item.update!(amount: self.seller_item.amount - self.amount, avg_sale_price: self.seller_item.sales.average(:total_price),
                               avg_sale_amount: self.seller_item.sales.average(:amount))
      # Also update med_batch to reflect remaining quantity
      self.med_batch.update!(total_units: self.med_batch.total_units - self.amount) if self.med_batch
    elsif self.receipt and self.receipt.receipt_type == 'adjustment' and adjust_item
      # When checking inventory, it is difficult to figure out which batch is missing
      # TODO: rethink how to update inventory count while keeping track of which batch is missing
      diff = self.new_total - self.adjust_item.amount
      price = diff * self.adjust_item.sale_price.amount if self.adjust_item and self.adjust_item.sale_price
      self.transaction_type = 'adjustment'
      self.amount = diff
      self.total_price = price
      receipt_value = receipt.total.nil? ? 0 : receipt.total
      self.receipt.update!(total: receipt_value + price)
      self.adjust_item.update!(amount: self.new_total)
    end
  end

  def item_existence
    errors.add(:transaction, 'must have an item') if seller_item_id.nil? and buyer_item_id.nil? and adjust_item_id.nil?
  end

  def author_existence
    errors.add(:transaction, 'need an user to sign off') if sale_user_id.nil? and purchase_user_id.nil? and adjust_user_id.nil?
  end

  def value_existence
    errors.add(:transaction, 'need an amount or new total value') if amount.nil? and new_total.nil?
  end

  def note_existence
    errors.add(:transaction, 'must have explanation when being edited') if notes.blank? and ((!amount_was.nil? and amount_changed?) or (!total_price_was.nil? and total_price_changed?))
  end

end

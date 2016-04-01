class Transaction < ActiveRecord::Base
  ### Attributes ###################################################################################
  enum transaction_type: ['activity', 'adjustment']

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################
  has_paper_trail

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
  before_save  :set_transaction_type
  before_save  :process_adjustment
  after_create :update_inventories
  after_update :edit_inventories

  ### Validations ##################################################################################
  # A store can sell to patients which does not have a buyer_id and buyer_item_id
  validates :due_date, :delivery_time, presence: true
  validate :author_existence, :item_existence, :value_existence, :note_existence, :matching_batch_item


  ### Scopes #######################################################################################

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################


  private
  def set_transaction_type
    if transaction_type.blank? and self.receipt and self.receipt.receipt_type == 'purchase' and buyer_item
      self.transaction_type = 'activity'
    elsif transaction_type.blank? and self.receipt and self.receipt.receipt_type == 'sale' and seller_item
      self.transaction_type = 'activity'
    elsif transaction_type.blank? and self.receipt and self.receipt.receipt_type == 'adjustment' and adjust_item
      self.transaction_type = 'adjustment'
    end
  end

  def process_adjustment
    if self.receipt and self.receipt.receipt_type == 'adjustment' and adjust_item
      self.amount = new_total - adjust_item.amount
      self.total_price = (new_total - adjust_item.amount) * adjust_item.sale_price.amount if adjust_item.sale_price
    end
  end

  def edit_inventories
    # Callback to correct users' mistakes. This is not the process to reconcile mismatch inventory count
    if receipt and receipt.receipt_type == 'purchase' and buyer_item
      if amount_changed?
        self.buyer_item.update!(amount: buyer_item.amount - amount_was + amount, avg_purchase_amount: self.buyer_item.purchases.average(:amount))
      end
      if med_batch and amount_changed?
        batch_params = {total_units: amount, user_id: purchase_user_id}
        batch_params = batch_params.merge!(total_price: total_price) if total_price_changed?
        batch_params = batch_params.merge!(paid: paid) if paid_changed?
        self.med_batch.update!(batch_params)
      end
      self.buyer_item.update!(avg_purchase_price: self.buyer_item.purchases.average(:total_price)) if total_price_changed?
    elsif receipt and receipt.receipt_type == 'sale' and seller_item
      if med_batch_id_changed?
        # Update with a different med_batch. Expect to receive both new batch_id and item_id.
        # First correct the old med_batch and inventories
        ob = MedBatch.find(med_batch_id_was)
        if ob
          ob.update!(total_units: ob.total_units + amount_was)
          ob.inventory_item.update!(amount: ob.inventory_item.amount + amount_was,
                                    avg_sale_amount: ob.inventory_item.sales.average(:amount),
                                    avg_sale_price: ob.inventory_item.sales.average(:total_price)) if ob.inventory_item
        end
        process_sale
      else
        # Update with the same med_batch
        seller_item_params = {}
        med_batch.update!(total_units: med_batch.total_units + amount_was - amount) if med_batch and amount_changed?
        seller_item_params = seller_item_params.merge({amount: seller_item.amount + amount_was - amount, avg_sale_amount: self.seller_item.sales.average(:amount)}) if amount_changed?
        seller_item_params = seller_item_params.merge({avg_sale_price: self.seller_item.sales.average(:total_price)}) if total_price_changed?
        seller_item.update!(seller_item_params) unless seller_item_params.blank?
      end
    end
    self.receipt.update!(total: self.receipt.total - total_price_was + total_price) if total_price_changed? and receipt
  end


  def update_inventories
    # After a transaction, update respective inventories and med_batches
    if self.receipt and self.receipt.receipt_type == 'purchase' and buyer_item
      self.buyer_item.update!(amount: self.buyer_item.amount + self.amount,
                        avg_purchase_price: self.buyer_item.purchases.average(:total_price),
                        avg_purchase_amount: self.buyer_item.purchases.average(:amount))
    elsif self.receipt and self.receipt.receipt_type == 'sale' and seller_item
      process_sale
    elsif self.receipt and self.receipt.receipt_type == 'adjustment' and adjust_item
      # When checking inventory, it is difficult to figure out which batch is missing
      # TODO: rethink how to update inventory count while keeping track of which batch is missing
      if adjust_item.sale_price
        # must check for sale price existence because that is a condition to update a new total price
        receipt_value = receipt.total.nil? ? 0 : receipt.total
        self.receipt.update!(total: receipt_value + total_price)
      end
      self.adjust_item.update!(amount: self.new_total)
    end
  end

  def process_sale
    self.seller_item.update!(amount: self.seller_item.amount - self.amount, avg_sale_price: self.seller_item.sales.average(:total_price),
                             avg_sale_amount: self.seller_item.sales.average(:amount))
    # Also update med_batch to reflect remaining quantity
    self.med_batch.update!(total_units: self.med_batch.total_units - self.amount) if self.med_batch
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

  def matching_batch_item
    if med_batch_id
      b = MedBatch.find(med_batch_id)
      errors.add(:transaction, 'must have matching batch with inventory item') if b.inventory_item_id != seller_item_id and b.inventory_item_id != buyer_item_id and b.inventory_item_id != adjust_item_id
    end
  end

end

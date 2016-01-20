class MedBatch < ActiveRecord::Base
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################
  belongs_to :medicine
  belongs_to :store
  belongs_to :user
  belongs_to :inventory_item
  belongs_to :category
  belongs_to :receipt

  has_many :transactions

  ### Callbacks ####################################################################################
  before_save :add_inventory_item
  after_create :update_receipt_transactions

  ### Validations ##################################################################################
  validates :mfg_date, :expire_date, :amount_per_pkg, :package, :amount_unit, presence: true
  validate :must_have_medicine

  ### Scopes #######################################################################################
  scope :available_batches, -> { where('total_units > ?', 0) }
  scope :empty_batches, -> {where('total_units = 0')}
  scope :non_expired_batches, -> {where('expire_date > ?', Date.today)}
  scope :expired_batches, -> {where('expire_date <= ?', Date.today)}
  scope :near_expire_batches, -> {where('expire_date <= ?', Date.today+30.days)}

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################


  private
  def must_have_medicine
    errors.add(:medicine, 'does not exist') if medicine.nil?
  end

  def add_inventory_item
    if store_id and user_id
      s = Store.find(store_id)
      inventory = s.inventory_items.find_or_create_by!(store_id: store_id, itemable_type: 'Medicine', itemable_id: medicine_id, category_id: category_id)
      self.inventory_item_id = inventory.id if inventory
    end
  end

  def update_receipt_transactions
    if store and user_id
      # Must query the database again to get the fresh copy of inventory in case item has just been created and not saved yet
      inventory = store.inventory_items.find_or_create_by!(store_id: store_id, itemable_type: 'Medicine', itemable_id: medicine_id, category_id: category_id)
      if inventory
        unless receipt_id
          # If there is no associated, we need to create a receipt to update inventory item status and count
          r = store.receipts.create!(receipt_type: 'purchase', store_id: store_id, total: self.total_price,
                                 transactions_attributes: [{amount: self.total_units, delivery_time: DateTime.now, buyer_id: store_id, med_batch_id: self.id,
                                                            due_date: DateTime.now, paid: self.paid, performed: true, transaction_type: 'activity',
                                                            purchase_user_id: user_id, buyer_item_id: inventory.id, total_price: self.total_price}])
          self.receipt_id = r.id
        else
          # If there is already a receipt, simply update add transaction
          Transaction.create!(receipt_id: receipt_id, amount: self.total_units, delivery_time: DateTime.now, med_batch_id: self.id,
                              due_date: DateTime.now, paid: self.paid, performed: true, transaction_type: 'activity',
                              purchase_user_id: user_id, buyer_item_id: inventory.id, total_price: self.total_price, buyer_id: store_id)
        end
      end
    end
  end

end

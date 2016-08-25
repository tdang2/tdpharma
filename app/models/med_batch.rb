class MedBatch < ActiveRecord::Base
  ### Attributes ###################################################################################
  include RandomGenerable

  ### Constants ####################################################################################
  enum status: [:active, :deprecated]

  ### Includes and Extensions ######################################################################
  has_paper_trail

  ### Associations #################################################################################
  belongs_to :medicine
  belongs_to :store
  belongs_to :user
  belongs_to :inventory_item
  belongs_to :category
  belongs_to :receipt

  has_many :purchase_transactions
  has_many :sale_transactions
  has_many :adjustment_transactions

  ### Callbacks ####################################################################################
  before_save :add_inventory_item
  after_create :create_receipt_transactions

  ### Validations ##################################################################################
  validates :mfg_date, :expire_date, :amount_per_pkg, :package, :number_pkg, :total_units, presence: true
  validate :must_have_medicine
  validate :have_matching_quantities

  ### Scopes #######################################################################################
  scope :available_batches, -> { active.where('total_units > ?', 0) }
  scope :empty_batches, -> {where('total_units = 0')}
  scope :non_expired_batches, -> {where('expire_date > ?', Date.today)}
  scope :expired_batches, -> {where('expire_date <= ?', Date.today)}
  scope :near_expire_batches, -> {where('expire_date <= ?', Date.today+30.days)}

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################


  private
  def have_matching_quantities
    errors.add(:med_batch, 'has inconsistent quantities') unless number_pkg * amount_per_pkg >= total_units
  end

  def must_have_medicine
    errors.add(:medicine, 'does not exist') if medicine.nil?
  end

  def add_inventory_item
    if store_id and user_id and inventory_item_id.blank?
      s = Store.find(store_id)
      inventory = s.inventory_items.find_or_create_by!(store_id: store_id, itemable_type: 'Medicine', itemable_id: medicine_id, category_id: category_id)
      self.inventory_item_id = inventory.id if inventory
    end
    self.barcode = MedBatch.barcode_generate if barcode.blank?
  end

  def create_receipt_transactions
    if store and user_id
      # Must query the database again to get the fresh copy of inventory in case item has just been created and not saved yet
      inventory = store.inventory_items.find_or_create_by!(store_id: store_id, itemable_type: 'Medicine', itemable_id: medicine_id, category_id: category_id)
      if inventory
        if receipt_id
          # If there is already a receipt, simply add transaction
          PurchaseTransaction.create!(receipt_id: receipt_id, amount: self.total_units, delivery_time: DateTime.now,
                                      med_batch_id: self.id, due_date: DateTime.now, paid: self.paid, performed: true,
                                      user_id: user_id, inventory_item_id: inventory.id, total_price: self.total_price,
                                      store_id: store_id)
        else
          # If there is no associated, we need to create a receipt to update inventory item status and count
          r = store.receipts.create!(receipt_type: 'purchase', store_id: store_id, total: self.total_price,
                                     purchase_transactions_attributes: [{amount: self.total_units, delivery_time: DateTime.now,
                                                                         store_id: store_id, med_batch_id: self.id, due_date: DateTime.now,
                                                                         paid: self.paid, performed: true, user_id: user_id,
                                                                         inventory_item_id: inventory.id, total_price: self.total_price}])
          self.update!(receipt_id: r.id)
        end
      end
    end
  end

end

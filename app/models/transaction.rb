class Transaction < ActiveRecord::Base
  ### Attributes ###################################################################################
  enum transaction_type: ['purchase', 'sale', 'adjustment']

  ### Constants ####################################################################################
  enum status: [:active, :deprecated]

  ### Includes and Extensions ######################################################################
  has_paper_trail

  ### Associations #################################################################################
  belongs_to :store
  belongs_to :inventory_item
  belongs_to :user
  belongs_to :receipt
  belongs_to :med_batch


  ### Callbacks ####################################################################################

  ### Validations ##################################################################################
  # A store can sell to patients which does not have a buyer_id and buyer_item_id
  validates :due_date, :delivery_time, presence: true
  validate :author_existence, :item_existence, :value_existence, :note_existence, :matching_batch_item


  ### Scopes #######################################################################################
  scope :created_max, ->(date) {where('created_at <= ?', date)}
  scope :created_min, ->(date) {where('created_at >= ?', date)}
  scope :updated_max, ->(date) {where('updated_at <= ?', date)}
  scope :updated_min, ->(date) {where('updated_at >= ?', date)}
  scope :by_inventory_item, -> (id) {where(inventory_item_id: id)}
  scope :by_user, -> (id) {where(user_id: id)}
  scope :by_med_batch, -> (id) {where(med_batch_id: id)}

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################


  protected

  def item_existence
    errors.add(:transaction, 'must have an item') if inventory_item.blank?
  end

  def author_existence
    errors.add(:transaction, 'need an user to sign off') if user.blank?
  end

  def value_existence
    errors.add(:transaction, 'need an amount or new total value') if amount.nil? and new_total.nil?
  end

  def note_existence
    if notes.blank? and ((!amount_was.nil? and amount_changed?) or (!total_price_was.nil? and total_price_changed?))
      errors[:notes] << 'must be provided when editing'
    end
  end

  def matching_batch_item
    if med_batch_id
      b = MedBatch.find(med_batch_id)
      errors.add(:med_batch, 'must match with inventory item') unless b.inventory_item_id == inventory_item_id
    end
  end

end

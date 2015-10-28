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


  ### Callbacks ####################################################################################
  after_save :update_inventories

  ### Validations ##################################################################################
  # A store can sell to patients which does not have a buyer_id and buyer_item_id
  validates :amount, :total_price, :due_date, :delivery_time, presence: true
  validate :author_existence, :item_existence


  ### Scopes #######################################################################################

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################


  private
  def update_inventories
    # After a transaction, update respective inventories
    if transaction_type == 'activity' and buyer_item_id
      self.buyer_item.update!(amount: self.buyer_item.amount + self.amount,
                        avg_purchase_price: self.buyer_item.purchases.average(:total_price),
                        avg_purchase_amount: self.buyer_item.purchases.average(:amount))
    elsif transaction_type == 'activity' and seller_item_id
      self.seller_item.update!(amount: self.seller_item.amount - self.amount, avg_sale_price: self.seller_item.sales.average(:total_price),
                               avg_sale_amount: self.seller_item.sales.average(:amount))
    elsif transaction_type == 'adjustment' and adjust_item_id
      self.adjust_item.update!(amount: self.adjust_item.amount + self.amount)
    end
  end

  def item_existence
    errors.add(:transaction, 'must have an item') if seller_item_id.nil? and buyer_item_id.nil?
  end

  def author_existence
    errors.add(:transaction, 'needs an user to sign off') if sale_user_id.nil? and purchase_user_id.nil?
  end
end

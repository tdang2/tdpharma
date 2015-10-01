class Transaction < ActiveRecord::Base
  ### Attributes ###################################################################################

  ### Constants ####################################################################################

  ### Includes and Extensions ######################################################################

  ### Associations #################################################################################
  belongs_to :buyer, class_name: Store, foreign_key: :buyer_id
  belongs_to :seller, class_name: Store, foreign_key: :seller_id
  belongs_to :seller_item, class_name: InventoryItem, foreign_key: :seller_item_id
  belongs_to :buyer_item, class_name: InventoryItem, foreign_key: :buyer_item_id
  belongs_to :sale_user, class_name: User, foreign_key: :sale_user_id
  belongs_to :purchase_user, class_name: User, foreign_key: :purchase_user_id

  ### Callbacks ####################################################################################
  after_save :update_inventories

  ### Validations ##################################################################################
  # A store can sell to patients which does not have a buyer_id and buyer_item_id
  validates :amount, :total_price, :due_date, presence: true
  validate :author_existence, :item_existence


  ### Scopes #######################################################################################

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################


  private
  def update_inventories
    # After a transaction, must update inventories of the seller.
  end

  def item_existence
    errors.add(:transaction, 'must have an item') if seller_item_id.nil? and buyer_item_id.nil?
  end

  def author_existence
    errors.add(:transaction, 'needs an user to sign off') if sale_user_id.nil? and purchase_user_id.nil?
  end
end

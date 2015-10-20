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

  ### Callbacks ####################################################################################
  before_save :add_inventory_item

  ### Validations ##################################################################################
  validates :mfg_date, :expire_date, :amount_per_pkg, :package, :amount_unit, presence: true
  validate :must_have_medicine

  ### Scopes #######################################################################################

  ### Other ########################################################################################


  ### Class Methods ################################################################################


  ### Instance Methods #############################################################################


  private
  def must_have_medicine
    errors.add(:medicine, 'does not exist') if medicine.nil?
  end

  def add_inventory_item
    if store_id and user_id
      inventory = Store.find(store_id).inventory_items.find_or_create_by!(store_id: store_id, itemable_type: 'Medicine', itemable_id: medicine_id, category_id: category_id)
      if inventory
        self.inventory_item_id =  inventory.id
        inventory.purchases.create!(amount: self.total_units, delivery_time: DateTime.now, buyer_id: store_id,
                                    due_date: DateTime.now, paid: true, performed: true, transaction_type: 'activity',
                                    purchase_user_id: user_id, buyer_item_id: inventory.id, total_price: self.total_price)
      end
    end
  end
end

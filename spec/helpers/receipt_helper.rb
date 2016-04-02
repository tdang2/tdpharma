RSpec.shared_context 'receipt params', :receipt_a => :receipt_b do
  # Use this params set up to test non controller methods
  let(:purchase_receipt_params) do
    {
        receipt_type: 'purchase',
        store_id: s.id,              # For client with user sign in, there is no need to provide for store_id
        med_batches_attributes: [{
                                     mfg_date: (Date.today - 3.months),
                                     expire_date: (Date.today + 3.months),
                                     package: 'Bottle',
                                     store_id: s.id,             # Same store as logged in user. No need to provide for client with logged in
                                     amount_per_pkg: 100,
                                     number_pkg: 1,
                                     total_units: 100,           # Total number of units (package * amount_per_pkg)
                                     total_price: 200,           # Total price for the whole transaction
                                     user_id: u1.id,
                                     category_id: item1.category.id,
                                     medicine_id: item1.itemable.id,    # must include medicine_id
                                     inventory_item_id: item1.id,       # must include inventory_item_id
                                     paid: true
                                 }, {
                                     mfg_date: (Date.today - 3.months),
                                     expire_date: (Date.today + 3.months),
                                     package: 'Box',
                                     store_id: s.id,            # Same store as logged in user. No need to provide for client with logged in
                                     amount_per_pkg: 27,
                                     number_pkg: 2,
                                     total_units: 54,           # Total number of units (package * amount_per_pkg)
                                     total_price: 300,          # Total price for the whole transaction
                                     user_id: u1.id,
                                     category_id: item2.category.id,
                                     medicine_id: item2.itemable.id,
                                     inventory_item_id: item2.id,
                                     paid: false
                                 }, {
                                     mfg_date: (Date.today - 3.months),
                                     expire_date: (Date.today + 3.months),
                                     package: 'Bottle',
                                     store_id: s.id,            # Same store as logged in user
                                     amount_per_pkg: 27,
                                     number_pkg: 1,
                                     total_units: 27,           # Total number of units (package * amount_per_pkg)
                                     total_price: 120,          # Total price for the whole transaction
                                     user_id: u1.id,
                                     category_id: item3.category.id,
                                     medicine_id: item3.itemable.id,
                                     inventory_item_id: item3.id,
                                     paid: true
                                 }]
    }
  end
  let(:sale_receipt_params) do
    {
        receipt_type: 'sale',
        store_id: s.id,               # No need for client side with logged in
        transactions_attributes: [{
                                      amount: 1,                  # quantity sold
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: true,
                                      performed: true,
                                      sale_user_id: u1.id,        # User id who make the sale
                                      seller_item_id: item1.id,   # Item id no need to provide for api request. only need batch id
                                      total_price: 100,           # total for the sale of this inventory item. Amount * sale price
                                      seller_id: s.id,            # No need for client side with logged in
                                      med_batch_id: item1.med_batches.first.id  # Batch id of the item
                                  }, {
                                      amount: 1,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: true,
                                      performed: true,
                                      sale_user_id: u1.id,
                                      seller_item_id: item4.id,   # Item id no need to provide for api request. only need batch id
                                      total_price: 54,            # total for the sale of this inventory item. Amount * sale price
                                      seller_id: s.id,            # No need for client side with logged in
                                      med_batch_id: item4.med_batches.first.id
                                  }
        ]
    }
  end
  let(:adjust_receipt_params) do
    {
        receipt_type: 'adjustment',
        store_id: s.id,
        transactions_attributes: [{
                                      new_total: 80,                  # New total value of the item after adjustment
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: false,                    # no payment involved
                                      performed: true,                # action is performed set to true
                                      adjust_user_id: u1.id,          # id of the user who makes the adjustment
                                      adjust_item_id: item2.id,       # id of the item which adjustment is made
                                      adjust_store_id: s.id,          # No need for client side with logged in user
                                      notes: 'Inventory Count Missing' # Note left by the user
                                  }, {
                                      new_total: 110,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: true,
                                      performed: true,
                                      adjust_user_id: u1.id,
                                      adjust_item_id: item3.id,
                                      adjust_store_id: s.id,
                                      notes: 'Found extra items on shelves'
                                  }
        ]
    }
  end
  let(:purchase_receipt_update_params) do
    {
        transactions_attributes: [
            {
                # id must be provided on the test level. Client must provide the id of the transaction that need to be updated
                amount: 150,                # quantity bought
                delivery_time: DateTime.now,
                due_date: DateTime.now,
                paid: false,
                performed: true,
                purchase_user_id: u2.id,    # User id who make the update
                total_price: 100,           # total for the sale of this inventory item. Amount * sale price
                notes: 'Must have this for update transaction'
            }
        ],
        med_batches_attributes: [
            {
                # Client must provide the id of the med_batch that needs to be updated. the id must match and belong to the transaction's inventory item
                # total_units will be updated by server through transaction's amount. Server will then check if total_units and amount_per_pkg are consistent with each other
                # user_id will be updated by server
                # total_price will be updated by server through transaction's total_price
                # paid will be updated by server through transaction's paid
                mfg_date: (Date.today - 1.months),
                expire_date: (Date.today + 6.months),
                package: 'Box',
                amount_per_pkg: 150,
                number_pkg: 1
            }
        ]
    }
  end
  let(:sale_receipt_update_params) do
    {
        transactions_attributes: [
            {
                amount: 10,               # quantity sold
                delivery_time: DateTime.tomorrow.beginning_of_day + 8.hours,    # New delivery time
                due_date: DateTime.tomorrow.beginning_of_day + 8.hours,         # New due date time
                paid: false,
                performed: false,
                total_price: 1000,                                              # user should have final decision how much to charge customers
                sale_user_id: u2.id,                                            # must provide who made the update
                seller_item_id: item1.id,                                       # must provide the item id as well. Server will check for consistency between batch and item
                med_batch_id: item1.med_batches.first.id,                       # must provide the batch id that get changed to
                notes: 'Must have this for update transaction'                  # must provide to update
            },
            {
                amount: 15,
                delivery_time: DateTime.tomorrow.beginning_of_day + 8.hours,
                due_date: DateTime.tomorrow.beginning_of_day + 8.hours,
                paid: false,
                performed: false,
                total_price: 875,
                sale_user_id: u2.id,
                seller_item_id: item2.id,                                      # in this edit, switch up the item
                med_batch_id: item2.med_batches.last.id,                        # in this edit, switch up the batch that belong to the new item
                notes: 'Must have this for update transaction'                  # must provide to update
            }
        ]
    }
  end
end
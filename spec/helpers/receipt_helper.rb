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
                                     amount_unit: 'tablet',      # Most minimum unit inside the package
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
                                     amount_unit: 'tablet',     # Most minimum unit inside the package
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
                                     amount_unit: 'tablet',     # Most minimum unit inside the package
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

end
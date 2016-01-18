RSpec.shared_context 'receipt params', :receipt_a => :receipt_b do
  # Use this params set up to test non controller methods
  let(:purchase_receipt_params) do
    {
        receipt_type: 'purchase',
        store_id: s.id,
        total: 620,
        med_batches_attributes: [{
                                     mfg_date: (Date.today - 3.months),
                                     expire_date: (Date.today + 3.months),
                                     package: 'Bottle',
                                     store_id: s.id,             # Same store as logged in user
                                     amount_per_pkg: 100,
                                     amount_unit: 'tablet',      # Most minimum unit inside the package
                                     total_units: 100,           # Total number of units (package * amount_per_pkg)
                                     total_price: 200,           # Total price for the whole transaction
                                     user_id: u1.id,
                                     category_id: item1.category.id,
                                     medicine_id: item1.itemable.id,
                                     inventory_item_id: item1.id,
                                     paid: true
                                 }, {
                                     mfg_date: (Date.today - 3.months),
                                     expire_date: (Date.today + 3.months),
                                     package: 'Box',
                                     store_id: s.id,            # Same store as logged in user
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
        store_id: s.id,
        total: 154,
        transactions_attributes: [{
                                      amount: 1,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: true,
                                      performed: true,
                                      sale_user_id: u1.id,
                                      seller_item_id: item1.id,
                                      total_price: 100,
                                      seller_id: s.id,
                                      med_batch_id: item1.med_batches.first.id
                                  }, {
                                      amount: 1,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: true,
                                      performed: true,
                                      sale_user_id: u1.id,
                                      seller_item_id: item4.id,
                                      total_price: 54,
                                      seller_id: s.id,
                                      med_batch_id: item4.med_batches.first.id
                                  }
        ]
    }
  end
  let(:adjust_receipt_params) do
    {
        receipt_type: 'adjustment',
        store_id: s.id,
        total: -2700,
        transactions_attributes: [{
                                      amount: -20,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: false,
                                      performed: true,
                                      adjust_user_id: u1.id,
                                      adjust_item_id: item2.id,
                                      total_price: -20 * 150,  # Expect clients to calculate the total adjust units * unit sale price
                                      adjust_store_id: s.id
                                  }, {
                                      amount: 10,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: true,
                                      performed: true,
                                      adjust_user_id: u1.id,
                                      adjust_item_id: item3.id,
                                      total_price: 10 * 30,  # Expect clients to calculate the total adjust units * unit sale price
                                      adjust_store_id: s.id,
                                  }
        ]
    }
  end

end
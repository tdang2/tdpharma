RSpec.shared_context 'transaction params', :transaction_a => :transaction_b do
  # Use this params set up to test non controller methods
  let(:purchase_receipt_params) do
    {
        receipt_type: 'purchase',
        store_id: s.id,
        total: 620,
        transactions_attributes: [{
                                      amount: 100,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: true,
                                      performed: true,
                                      purchase_user_id: u1.id,
                                      buyer_item_id: item1.id,
                                      total_price: 200,
                                      buyer_id: s.id,
                                      transaction_type: 'activity'
                                  }, {
                                      amount: 54,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: true,
                                      performed: true,
                                      purchase_user_id: u1.id,
                                      buyer_item_id: item2.id,
                                      total_price: 300,
                                      buyer_id: s.id,
                                      transaction_type: 'activity'
                                  }, {
                                      amount: 27,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: true,
                                      performed: true,
                                      purchase_user_id: u1.id,
                                      buyer_item_id: item3.id,
                                      total_price: 120,
                                      buyer_id: s.id,
                                      transaction_type: 'activity'
                                  }
        ]
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
                                      transaction_type: 'activity'
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
                                      transaction_type: 'activity'
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
                                      adjust_store_id: s.id,
                                      transaction_type: 'adjustment'
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
                                      transaction_type: 'adjustment'
                                  }
        ]
    }
  end
  # Use the following params set up for controller methods
  let(:purchase_receipt_controller_params) do
    {
        receipt_type: 'purchase',
        total: 620,
        transactions_attributes: [{
                                      amount: 100,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: true,
                                      performed: true,
                                      purchase_user_id: u1.id,
                                      buyer_item_id: item1.id,
                                      total_price: 200
                                  }, {
                                      amount: 54,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: true,
                                      performed: true,
                                      purchase_user_id: u1.id,
                                      buyer_item_id: item2.id,
                                      total_price: 300
                                  }, {
                                      amount: 27,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: true,
                                      performed: true,
                                      purchase_user_id: u1.id,
                                      buyer_item_id: item3.id,
                                      total_price: 120
                                  }]
    }
  end
  let(:sale_receipt_controller_params) do
    {
        receipt_type: 'sale',
        total: 154,
        transactions_attributes: [{
                                      amount: 1,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: true,
                                      performed: true,
                                      sale_user_id: u1.id,
                                      seller_item_id: item1.id,
                                      total_price: 100
                                  }, {
                                      amount: 1,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: true,
                                      performed: true,
                                      sale_user_id: u1.id,
                                      seller_item_id: item4.id,
                                      total_price: 54
                                  }
        ]
    }
  end
  let(:adjust_receipt_controller_params) do
    {
        receipt_type: 'adjustment',
        total: -2700,
        transactions_attributes: [{
                                      amount: -20,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: false,
                                      performed: true,
                                      adjust_user_id: u1.id,
                                      adjust_item_id: item2.id,
                                      total_price: -20 * 150  # Expect clients to calculate the total adjust units * unit sale price
                                  }, {
                                      amount: 10,
                                      delivery_time: DateTime.now,
                                      due_date: DateTime.now,
                                      paid: true,
                                      performed: true,
                                      adjust_user_id: u1.id,
                                      adjust_item_id: item3.id,
                                      total_price: 10 * 30  # Expect clients to calculate the total adjust units * unit sale price
                                  }
        ]
    }
  end
end
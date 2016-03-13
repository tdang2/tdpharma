RSpec.shared_context 'transaction params', :transaction_a => :transaction_b do
  let(:purchase_transaction_edit_params) do
    {
      amount: 50,                  # edit quantity purchase
      delivery_time: DateTime.now,
      due_date: DateTime.now,
      paid: true,
      performed: true,
      purchase_user_id: u1.id,    # User id who make the purchase edit
      purchase_item_id: item2.id, # Item id can not be changed. Insert here for test only. Will ignore in update logic
      total_price: 250,           # total for the purchase of this inventory item batch
      buyer_id: s.id,            # No need for client side with logged in info
      med_batch_id: item1.med_batches.first.id,  # Batch id of the item. Can not be changed for edit. Insert here to test only
      notes: 'Correct fat finger mistakes'
    }
  end

  let(:sale_transaction_edit_params) do
    {
        amount: 2,                # edit quantity sale
        delivery_time: DateTime.now,
        due_date: DateTime.now,
        paid: true,
        performed: true,
        sale_user_id: u1.id,     # User id who made the sale edit
        sale_item_id: item2.id,  # Item id can not be changed. Insert here for test only. Will ignore in update logic
        total_price: 200,        # total for the sale of this inventory item batch
        seller_id: s.id,         # No need for client side with logged in info
        med_batch_id: item1.med_batches.first.id, # Batch id of the item. Can not be changed for edit. Insert here to test only
        notes: 'Correct fat finger mistakes'
    }
  end
end
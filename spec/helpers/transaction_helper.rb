RSpec.shared_context 'transaction params', :transaction_a => :transaction_b do
  let(:purchase_transaction_edit_params) do
    {
      amount: 50,                  # edit quantity purchase
      delivery_time: DateTime.now,
      due_date: DateTime.now,
      paid: true,
      performed: true,
      purchase_user_id: u1.id,    # User id who make the purchase edit
      buyer_item_id: item1.id,    # id of inventory item. only need to provide when change purchase inventory item
      total_price: 250,           # total for the purchase of this inventory item batch
      buyer_id: s.id,            # No need for client side with logged in info
      med_batch_id: item1.med_batches.last.id,  # Batch id of the item. batch must belong to the matching inventory item
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
        seller_item_id: item1.id,  # Item id must be provided and match batch id
        total_price: 200,        # total for the sale of this inventory item batch
        seller_id: s.id,         # No need for client side with logged in info
        med_batch_id: item1.med_batches.last.id, # Batch id of the item.
        notes: 'Correct fat finger mistakes'
    }
  end

  let(:sale_different_batch_edit_params) do
    {
        amount: 5,              # edit quantity sale
        delivery_time: DateTime.tomorrow.beginning_of_day + 8.hours,
        due_date: DateTime.tomorrow.beginning_of_day + 8.hours,
        paid: false,
        performed: false,
        sale_user_id: u2.id,    # must provide user id who perform the update
        seller_item_id: item2.id, # new item id that will be sold instead of item 1
        total_price: 150,         # price for this sale transaction. Allow user to decide the price
        seller_id: s.id,          # No need for client side with logged in info
        med_batch_id: item2.med_batches.first.id,     # new batch id for item 2 instead of item 1
        notes: 'Change the medicine and deliver tomorrow'
    }
  end
end
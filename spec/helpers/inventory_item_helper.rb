RSpec.shared_context 'inventory item params', :ii_a => :ii_b do
  let(:item1) do
    b = create(:med_batch, category_id: @c3.id, user: u1, store: @s, medicine: med1)
    b.inventory_item
  end
  let(:item2) do
    b = create(:med_batch, category_id: @c2.id, user: u1, store: @s, medicine: med2)
    b.inventory_item
  end
  let(:item3) do
    b = create(:med_batch, category_id: @c3.id, user: u1, store: @s, medicine: med3)
    b.inventory_item
  end
  let(:item4) do
    b = create(:med_batch, category_id: @c2.id, user: u1, store: @s, medicine: med4)
    b.inventory_item
  end
  let(:inventory_item_new_price_params) do
    {
        sale_price_attributes: {
            amount: 200,
            discount: 10
        }
    }
  end
  let(:inventory_item_price_params) do
    {
        sale_price_attributes: {
            id: item1.sale_price.id,
            amount: 200,
            discount: 10
        }
    }
  end
end
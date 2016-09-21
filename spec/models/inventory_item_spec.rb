require 'rails_helper'

RSpec.describe InventoryItem, type: :model do
  include_context 'user params'
  include_context 'category params'
  include_context 'medicine params'
  include_context 'inventory item params'

  it {should belong_to :store}
  it {should belong_to :category}
  it {should have_many :med_batches}
  it {should have_many :good_batches}
  it {should have_many :empty_batches}
  it {should have_many :available_batches}
  it {should belong_to :itemable}
  it {should have_many :purchase_transactions}
  it {should have_many :sale_transactions}
  it {should have_many :adjustment_transactions}
  it {should have_one :sale_price}
  it {should have_one :image}


  describe 'scope test' do
    before do
      prepare_data
      u1.update!(store_id: s.id)
      item1.create_sale_price(amount: 100, discount: 0)
      item2.create_sale_price(amount: 150, discount: 0)
      item4
      item3.update!(status: 'inactive')
    end

    it '.active' do
      items = s.inventory_items.active
      expect(items).to include item2
      expect(items).not_to include item3
      expect(items.all? {|i| !i.itemable.nil? }).to be true
      expect(items.all? {|i| i.available_batches.all? {|b| b.status == 'active'}}).to be true
    end

    it '.active not include deprecated med_batches' do
      item4.med_batches.last.update!(status: 'deprecated')
      items = s.inventory_items.active
      expect(items).to include item4
      i4 = items.find(item4.id)
      expect(i4.available_batches).not_to include item4.med_batches.last
    end

    it '.inactive' do
      items = s.inventory_items.inactive
      expect(items).to include item3
      expect(items).not_to include item1
      expect(items.find(item3.id).available_batches).not_to be_empty
    end

    it 'with zero sale price or no sale price' do
      item3.create_sale_price(amount: 0)
      items = s.inventory_items.without_sale_price
      expect(items).to include item3
      expect(items).to include item4
      expect(items).not_to include item1, item2
    end

    it 'out_of_stock' do
      sale = create(:sale_receipt, store: s)
      create(:sale_transaction, store: s, med_batch: item1.med_batches.first, amount: 100, user: u1, inventory_item: item1, receipt: sale)
      items = s.inventory_items.out_of_stock
      expect(items).to include item1
      expect(items).not_to include item2, item3, item4
    end
  end

end

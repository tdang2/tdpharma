require 'rails_helper'

RSpec.describe Receipt, type: :model do
  include_context 'user params'
  include_context 'category params'
  include_context 'medicine params'
  include_context 'inventory item params'
  include_context 'receipt params'

  it {should belong_to :store}
  it {should have_many :transactions}
  it {should have_many :med_batches}
  it {should have_many :purchase_transactions}
  it {should have_many :sale_transactions}
  it {should have_many :adjustment_transactions}

  describe 'testing scope' do

    it '.created_max' do
      s1 = create(:sale_receipt)
      p1 = create(:purchase_receipt)
      date = Time.zone.today
      Timecop.travel(date + 4.days)
      s2 = create(:sale_receipt)
      p2 = create(:purchase_receipt)
      expect(Receipt.created_max(date + 2.days)).to include s1, p1
      expect(Receipt.created_max(date + 2.days)).not_to include s2, p2
    end

    it '.created_min' do
      s1 = create(:sale_receipt)
      p1 = create(:purchase_receipt)
      date = Time.zone.today
      Timecop.travel(date + 4.days)
      s2 = create(:sale_receipt)
      p2 = create(:purchase_receipt)
      expect(Receipt.created_min(date + 2.days)).to include s2, p2
      expect(Receipt.created_min(date + 2.days)).not_to include s1, p1
    end
  end
end

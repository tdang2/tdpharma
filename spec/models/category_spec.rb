require 'rails_helper'
require 'helpers/category_helper'

RSpec.describe Category, type: :model do
  it {should validate_presence_of :name}
  it {should have_many :inventory_items}
  it {should have_and_belong_to_many :stores}
  it {should have_one :image}

  describe 'logic test' do
    before do
      prepare_data
    end
    describe 'get_store_categories logic' do
      before do
        @res = Category.get_store_categories(@s.id)
      end
      it 'has 2 master categories' do
        expect(@res.count).to eq 2
      end
      it 'has 2 children for 1st master cat' do
        expect(@res[0][:children].count).to eq 2
      end
      it 'has 1 child for 2nd master cat' do
        expect(@res[1][:children].count).to eq 1
      end
      it 'has 1 3rd level cat' do
        expect(@res[0][:children][0][:children].count).to eq 1
      end
    end

  end
end

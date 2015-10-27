require 'rails_helper'
require 'helpers/user_helper'
require 'helpers/category_helper'

RSpec.describe Category, type: :model do
  it {should validate_presence_of :name}
  it {should have_many :inventory_items}
  it {should have_many :med_batches}
  it {should have_and_belong_to_many :stores}
  it {should have_one :image}

  describe 'scope test' do
    include_context 'user params'
    include_context 'category params'
    before do
      prepare_data
    end
    it 'base level scope' do
      expect(Category.base_level.to_a).to eq Category.where(parent_id: nil).to_a
    end
    it 'last level scope' do
      expect(Category.last_level.to_a).to eq Category.where.not(parent_id: nil).where(children_count: 0).to_a
    end
  end

  describe 'logic test' do
    include_context 'user params'
    include_context 'category params'
    before do
      prepare_data
    end
    describe 'get_store_categories logic' do
      before do
        @res = Category.get_store_categories(s.id)
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

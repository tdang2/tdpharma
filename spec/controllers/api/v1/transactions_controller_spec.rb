require 'rails_helper'

RSpec.describe Api::V1::TransactionsController, type: :controller do
  include_context 'user params'
  include_context 'category params'
  include_context 'medicine params'
  include_context 'inventory item params'
  include_context 'receipt params'
  include_context 'transaction params'

  before do
    prepare_data
    u1.update!(store_id: s.id)
  end

  describe 'patch UPDATE' do
    before do
      request.headers['Authorization'] = "#{u1.email}:#{u1.authentication_token}"
    end
    describe 'For purchase transactions' do
      before do
        @pre_item1_avg_pur_cnt = item1.avg_purchase_amount
        @r = Receipt.create!(purchase_receipt_params)
        @t = @r.transactions.where(buyer_item_id: item1.id).last
      end
      it 'fail editing purchase without explanation notes' do
        purchase_transaction_edit_params.delete(:notes)
        patch :update, id: @t.id, transaction: purchase_transaction_edit_params, format: :json
        expect(response.status).to eq 400
        expect(JSON.parse(response.body)['data']['errors']).to eq 'Validation failed: Transaction must have explanation when being edited'
      end

      it 'fails editing purchase with mismatch batch and item' do
        purchase_transaction_edit_params['buyer_item_id'] = item2.id
        patch :update, id: @t.id, transaction: purchase_transaction_edit_params, format: :json
        expect(response.status).to eq 400
        expect(JSON.parse(response.body)['data']['errors']).to eq 'Validation failed: Transaction must have matching batch with inventory item'
      end

      it 'reverse a purchase transaction' do
        r_total = @r.total
        t_total = @t.total_price
        t_cnt = @t.amount
        i1_cnt = InventoryItem.find(item1.id).amount
        @params = purchase_transaction_edit_params.merge({status: 'deprecated'})
        patch :update, id: @t.id, transaction: @params, format: :json
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['data']['status']).to eq 'deprecated'
        expect(JSON.parse(response.body)['data']['receipt']['total']).to eq r_total - t_total
        expect(MedBatch.find(@t.med_batch.id).status).to eq 'deprecated'
        expect(InventoryItem.find(item1.id).amount).to eq i1_cnt - t_cnt
        expect(InventoryItem.find(item1.id).avg_purchase_amount).to eq @pre_item1_avg_pur_cnt
      end

      it 'edit purchase info' do
        r_total = @r.total
        t_total = @t.total_price
        t_cnt = @t.amount
        barcode = InventoryItem.find(item1.id).med_batches.where(receipt_id: @r.id).last.barcode
        i1_cnt = InventoryItem.find(item1.id).amount
        i1_avg_cnt = InventoryItem.find(item1.id).avg_purchase_amount
        patch :update, id: @t.id, transaction: purchase_transaction_edit_params, format: :json
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['data']['receipt']['id']).to eq @r.id
        expect(JSON.parse(response.body)['data']['amount']).to eq 50
        expect(JSON.parse(response.body)['data']['buyer_item_id']).to eq item1.id
        expect(JSON.parse(response.body)['data']['receipt']['total']).to eq r_total - t_total + 250
        expect(MedBatch.find(@t.med_batch.id).total_price).to eq 250
        expect(MedBatch.find(@t.med_batch.id).total_units).to eq 50
        expect(MedBatch.find(@t.med_batch.id).barcode).to eq barcode
        expect(InventoryItem.find(item1.id).amount).to eq i1_cnt - t_cnt + 50
        expect(InventoryItem.find(item1.id).avg_purchase_amount).not_to eq i1_avg_cnt
      end
    end

    describe 'Sale transactions' do
      before do
        @pre_item1_avg_sale_cnt = item1.avg_sale_amount
        @r = Receipt.create!(sale_receipt_params)
        @t = @r.transactions.where(seller_item_id: item1.id).last
      end

      it 'fail editing sale without explanation notes' do
        sale_transaction_edit_params.delete(:notes)
        patch :update, id: @t.id, transaction: sale_transaction_edit_params, format: :json
        expect(response.status).to eq 400
        expect(JSON.parse(response.body)['data']['errors']).to eq 'Validation failed: Transaction must have explanation when being edited'
      end

      it 'fail editing sale with mismatch batch and item' do
        sale_transaction_edit_params['seller_item_id'] = item2.id
        patch :update, id: @t.id, transaction: sale_transaction_edit_params, format: :json
        expect(response.status).to eq 400
        expect(JSON.parse(response.body)['data']['errors']).to eq 'Validation failed: Transaction must have matching batch with inventory item'
      end

      it 'reverse sale transaction' do
        t_cnt = @t.amount
        r_total = @r.total
        t_total = @t.total_price
        i1_cnt = InventoryItem.find(item1.id).amount
        @params = sale_transaction_edit_params.merge({status: 'deprecated'})
        patch :update, id: @t.id, transaction: @params, format: :json
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['data']['status']).to eq 'deprecated'
        expect(JSON.parse(response.body)['data']['receipt']['total']).to eq r_total - t_total
        expect(InventoryItem.find(item1.id).amount).to eq i1_cnt + t_cnt
        expect(InventoryItem.find(item1.id).avg_sale_amount).to eq @pre_item1_avg_sale_cnt
      end

      it 'edit sale info' do
        t_cnt = @t.amount
        r_total = @r.total
        t_total = @t.total_price
        barcode = @t.med_batch.barcode
        batch_cnt = @t.med_batch.total_units
        i1_cnt = InventoryItem.find(item1.id).amount
        i1_avg_cnt = InventoryItem.find(item1.id).avg_sale_amount
        patch :update, id: @t.id, transaction: sale_transaction_edit_params, format: :json
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['data']['receipt']['id']).to eq @r.id
        expect(JSON.parse(response.body)['data']['amount']).to eq 2
        expect(JSON.parse(response.body)['data']['seller_item_id']).to eq item1.id
        expect(JSON.parse(response.body)['data']['receipt']['total']).to eq r_total - t_total + 200
        expect(MedBatch.find(@t.med_batch.id).total_units).to eq batch_cnt + t_cnt - 2
        expect(MedBatch.find(@t.med_batch.id).barcode).to eq barcode
        expect(InventoryItem.find(item1.id).amount).to eq i1_cnt + t_cnt - 2
        expect(InventoryItem.find(item1.id).avg_sale_amount).not_to eq i1_avg_cnt
      end

      it 'edit sale with diff batch' do
        t_cnt = @t.amount
        r_total = @r.total
        t_total = @t.total_price
        new_batch_cnt = item2.med_batches.first.total_units
        new_item_cnt = item2.amount
        barcode = item2.med_batches.first.barcode
        new_item_avg_cnt = item2.avg_sale_amount
        old_batch_cnt = @t.med_batch.total_units
        old_item_cnt = InventoryItem.find(item1.id).amount
        patch :update, id: @t.id, transaction: sale_different_batch_edit_params, format: :json
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['data']['receipt']['id']).to eq @r.id
        expect(JSON.parse(response.body)['data']['amount']).to eq 5
        expect(JSON.parse(response.body)['data']['seller_item_id']).to eq item2.id
        expect(JSON.parse(response.body)['data']['receipt']['total']).to eq r_total - t_total + 150
        expect(MedBatch.find(item2.med_batches.first.id).total_units).to eq new_batch_cnt - 5
        expect(MedBatch.find(item2.med_batches.first.id).barcode).to eq barcode
        expect(MedBatch.find(@t.med_batch.id).total_units).to eq old_batch_cnt + t_cnt
        expect(InventoryItem.find(item1.id).amount).to eq old_item_cnt + t_cnt
        expect(InventoryItem.find(item1.id).avg_sale_amount).to eq @pre_item1_avg_sale_cnt
        expect(InventoryItem.find(item2.id).amount).to eq new_item_cnt - 5
        expect(InventoryItem.find(item2.id).avg_sale_amount).not_to eq new_item_avg_cnt
      end
    end
  end

  describe 'show GET' do
    before do
      request.headers['Authorization'] = "#{u1.email}:#{u1.authentication_token}"
    end
    it 'show correct purchase' do
      r = Receipt.create!(purchase_receipt_params)
      t_id = item1.purchases.last.id
      get :show, id: t_id, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['receipt']['receipt_type']).to eq 'purchase'
      expect(JSON.parse(response.body)['data']['buyer_item']['id']).to eq item1.id
      expect(r.med_batches.map(&:id)).to include JSON.parse(response.body)['data']['med_batch']['id']
    end

    it 'show correct sale' do
      item1.create_sale_price(amount: 100, discount: 0)   # initialized 100 units for item1
      item4.create_sale_price(amount: 100, discount: 0)   # initialized 100 units for item4
      r = Receipt.create!(sale_receipt_params)
      t_id = item4.sales.last.id
      get :show, id: t_id, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['receipt']['receipt_type']).to eq 'sale'
      expect(JSON.parse(response.body)['data']['seller_item']['id']).to eq item4.id
      expect(r.transactions.map {|t| t.med_batch.id}).to include JSON.parse(response.body)['data']['med_batch']['id']
    end

    it 'show correct adjustment' do
      item2.create_sale_price(amount: 100, discount: 0)   # initialized 100 units for item2
      item3.create_sale_price(amount: 100, discount: 0)   # initialized 100 units for item3
      r = Receipt.create!(adjust_receipt_params)
      t_id = item3.adjustments.last.id
      get :show, id: t_id, format: :json
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']['receipt']['receipt_type']).to eq 'adjustment'
      expect(JSON.parse(response.body)['data']['adjust_item']['id']).to eq item3.id
      expect(JSON.parse(response.body)['data']['med_batch']).to be nil
    end
  end
end
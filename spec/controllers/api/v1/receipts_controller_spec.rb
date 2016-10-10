require 'rails_helper'

RSpec.describe Api::V1::ReceiptsController, type: :controller do
  include_context 'user params'
  include_context 'category params'
  include_context 'medicine params'
  include_context 'inventory item params'
  include_context 'receipt params'

  before do
    prepare_data
    u1.update!(store_id: s.id)
    item1.create_sale_price(amount: 100, discount: 0)   # initialized 100 units for item1
    item2.create_sale_price(amount: 150, discount: 0)   # initialized 100 units for item2
    item3.create_sale_price(amount: 30, discount: 0)    # initialized 100 units for item3
    item4.create_sale_price(amount: 54, discount: 0)    # initialized 100 units for item4
  end

  describe 'GET index' do
    before do
      Receipt.create!(purchase_receipt_params)
      Receipt.create!(sale_receipt_params)
      Receipt.create!(adjust_receipt_params)
    end
    it 'list all receipts' do
      get :index, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['receipts'].count).to be >= 3
    end
    it 'list all sales' do
      get :index, sale: true, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['receipts'].all?{|r| r['receipt_type'] == 'sale'}).to eq true
    end
    it 'list all purchases' do
      get :index, purchase: true, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['receipts'].all?{|r| r['receipt_type'] == 'purchase'}).to eq true
    end
    it 'list all adjustment' do
      get :index, adjustment: true, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['receipts'].all?{|r| r['receipt_type'] == 'adjustment'}).to eq true
    end
    it 'list receipt with created_max' do
      date = Time.zone.today
      Timecop.travel(date + 4.days)
      get :index, created_max: date + 2.days, format: :json, access_token: token.token
      expect(response.status).to eq 200
    end
    it 'list receipts with created_min' do
      date = Time.zone.today
      Timecop.travel(date + 4.days)
      get :index, created_min: date + 2.days, format: :json, access_token: token.token
      expect(response.status).to eq 200
    end
  end

  describe 'CREATE post' do
    it 'create purchase receipt' do
      item1_cnt = InventoryItem.find(item1.id).amount
      item2_cnt = InventoryItem.find(item2.id).amount
      item3_cnt = InventoryItem.find(item3.id).amount
      post :create, receipt: purchase_receipt_params, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(InventoryItem.find(item1.id).amount).to eq item1_cnt + 100
      expect(InventoryItem.find(item2.id).amount).to eq item2_cnt + 54
      expect(InventoryItem.find(item3.id).amount).to eq item3_cnt + 27
      expect(Receipt.find(JSON.parse(response.body)['id']).transactions.count).to eq 3
      expect(JSON.parse(response.body)['receipt_type'] == 'purchase').to eq true
      expect(JSON.parse(response.body)['total']).to eq 620
      expect(JSON.parse(response.body)['barcode']).not_to eq nil
      expect(JSON.parse(response.body)['transactions'].all?{|t| !t['inventory_item_id'].nil?}).to eq true
      expect(JSON.parse(response.body)['transactions'].all?{|t| t['transaction_type'] == 'PurchaseTransaction'}).to eq true
    end
    it 'create sale receipt' do
      item1_cnt = InventoryItem.find(item1.id).amount
      item4_cnt = InventoryItem.find(item4.id).amount
      post :create, receipt: sale_receipt_params, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(InventoryItem.find(item1.id).amount).to eq item1_cnt - 1
      expect(InventoryItem.find(item4.id).amount).to eq item4_cnt - 1
      expect(JSON.parse(response.body)['receipt_type'] == 'sale').to eq true
      expect(JSON.parse(response.body)['total']).to eq 154
      expect(JSON.parse(response.body)['barcode']).not_to eq nil
      expect(JSON.parse(response.body)['transactions'].all?{|t| !t['inventory_item_id'].nil?}).to eq true
      expect(JSON.parse(response.body)['transactions'].all?{|t| t['transaction_type'] == 'SaleTransaction'}).to eq true
    end
    it 'same barcode for batch through purchase sale process' do
      item1_cnt = InventoryItem.find(item1.id).amount
      post :create, receipt: purchase_receipt_params, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(InventoryItem.find(item1.id).amount).to eq item1_cnt + 100
      barcode = InventoryItem.find(item1.id).med_batches.first.barcode
      batch_cnt = InventoryItem.find(item1.id).med_batches.first.total_units
      post :create, receipt: sale_receipt_params, format: :json
      expect(response.status).to eq 200
      expect(InventoryItem.find(item1.id).amount).to eq item1_cnt + 100 - 1
      expect(InventoryItem.find(item1.id).med_batches.first.total_units).to eq batch_cnt - 1
      expect(InventoryItem.find(item1.id).med_batches.first.barcode).to eq barcode
    end
    it 'create adjustment receipt' do
      item2_cnt = InventoryItem.find(item2.id).amount
      item3_cnt = InventoryItem.find(item3.id).amount
      post :create, receipt: adjust_receipt_params, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(InventoryItem.find(item2.id).amount).to eq item2_cnt - 20
      expect(InventoryItem.find(item3.id).amount).to eq item3_cnt + 10
      expect(JSON.parse(response.body)['total']).to eq -20*150 + 10*30
      expect(JSON.parse(response.body)['receipt_type'] == 'adjustment').to eq true
      expect(JSON.parse(response.body)['barcode']).not_to eq nil
      expect(JSON.parse(response.body)['transactions'].all?{|t| !t['inventory_item_id'].nil?}).to eq true
      expect(JSON.parse(response.body)['transactions'].all?{|t| t['transaction_type'] == 'AdjustmentTransaction'}).to eq true
    end
  end

  describe 'SHOW get' do
    it 'show receipt purchase' do
      Receipt.create!(purchase_receipt_params)
      receipt_id = item1.purchase_transactions.last.receipt.id
      get :show, id: receipt_id, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['receipt_type']).to eq 'purchase'
      expect(JSON.parse(response.body)['transactions'].length).to eq 3
      expect(JSON.parse(response.body)['transactions'].any?{|t| t['inventory_item_id'] == item1.id}).to eq true
      expect(JSON.parse(response.body)['transactions'].any?{|t| t['inventory_item_id'] == item2.id}).to eq true
      expect(JSON.parse(response.body)['transactions'].any?{|t| t['inventory_item_id'] == item3.id}).to eq true
    end
    it 'show sale receipt' do
      Receipt.create!(sale_receipt_params)
      get :show, id:  item1.sale_transactions.last.receipt.id, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['receipt_type']).to eq 'sale'
      expect(JSON.parse(response.body)['transactions'].length).to eq 2
      expect(JSON.parse(response.body)['transactions'].any?{|t| t['inventory_item_id'] == item1.id}).to eq true
      expect(JSON.parse(response.body)['transactions'].any?{|t| t['inventory_item_id'] == item4.id}).to eq true
    end
    it 'show adjustment receipt' do
      Receipt.create!(adjust_receipt_params)
      get :show, id: item2.adjustment_transactions.last.receipt.id, format: :json, access_token: token.token
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['receipt_type']).to eq 'adjustment'
      expect(JSON.parse(response.body)['transactions'].length).to eq 2
      expect(JSON.parse(response.body)['transactions'].any?{|t| t['inventory_item_id'] == item2.id}).to eq true
      expect(JSON.parse(response.body)['transactions'].any?{|t| t['inventory_item_id'] == item3.id}).to eq true
    end
  end

  describe 'PATCH update' do

    describe 'Purchase receipt' do
      before do
        @r = Receipt.create!(purchase_receipt_params)
        @t = @r.transactions.where(inventory_item_id: item1.id).last
        @params = purchase_receipt_update_params
        @params[:purchase_transactions_attributes][0] = @params[:purchase_transactions_attributes][0].merge({id: @t.id})
        @params[:med_batches_attributes][0] = @params[:med_batches_attributes][0].merge({id: @t.med_batch.id})
      end
      it 'not allow to update without author' do
        @params[:purchase_transactions_attributes][0].delete :user_id
        patch :update, id: @r.id, receipt: @params, format: :json, access_token: token.token
        expect(response.status).to eq 400
        expect(JSON.parse(response.body)['errors']).to eq 'Author is required'
      end
      it 'not allow to update without notes' do
        @params[:purchase_transactions_attributes][0].delete :notes
        patch :update, id: @r.id, receipt: @params, format: :json, access_token: token.token
        expect(response.status).to eq 400
        expect(JSON.parse(response.body)['errors']).to eq 'Validation failed: Purchase transactions notes must be provided when editing'
      end
      it 'failed with mismatch batch and inventory item' do
        @params[:purchase_transactions_attributes][0]['med_batch_id'] = item2.med_batches.last.id
        patch :update, id: @r.id, receipt: @params, format: :json, access_token: token.token
        expect(response.status).to eq 400
        expect(JSON.parse(response.body)['errors']).to eq 'Validation failed: Purchase transactions med batch must match with inventory item'
      end
      it 'reverse a purchase transaction' do
        @params.delete :med_batches_attributes
        @params[:purchase_transactions_attributes][0] = @params[:purchase_transactions_attributes][0].merge({status: 'deprecated'})
        @params[:purchase_transactions_attributes][0].delete :total_price
        receipt_total = @r.total
        pre_amount = @t.amount
        pre_price = @t.total_price
        i1_cnt = InventoryItem.find(item1.id).amount
        patch :update, id: @r.id, receipt: @params, format: :json, access_token: token.token
        expect(response.status).to eq 200
        expect(Transaction.find(@t.id).status).to eq 'deprecated'
        expect(Transaction.find(@t.id).user_id).to eq u2.id
        expect(Transaction.find(@t.id).paid).to eq false
        expect(MedBatch.find(@t.med_batch.id).status).to eq 'deprecated'
        expect(MedBatch.find(@t.med_batch.id).user_id).to eq u2.id
        expect(Receipt.find(@r.id).total).to eq receipt_total - pre_price
        expect(InventoryItem.find(item1.id).amount).to eq i1_cnt - pre_amount
      end
      it 'update on both transaction and med_batch' do
        receipt_total = @r.total
        pre_transaction_amount = @t.amount
        pre_transaction_price = @t.total_price
        i1_cnt = InventoryItem.find(item1.id).amount
        patch :update, id: @r.id, receipt: @params, format: :json, access_token: token.token
        expect(response.status).to eq 200
        expect(Transaction.find(@t.id).amount).to eq 150
        expect(Transaction.find(@t.id).user_id).to eq u2.id
        expect(MedBatch.find(@t.med_batch.id).total_units).to eq 150
        expect(MedBatch.find(@t.med_batch.id).user_id).to eq u2.id
        expect(MedBatch.find(@t.med_batch.id).paid).to eq false
        expect(Receipt.find(@r.id).total).to eq receipt_total - pre_transaction_price + 100
        expect(InventoryItem.find(item1.id).amount).to eq i1_cnt - pre_transaction_amount + 150
      end
    end

    describe 'Sale receipt' do
      before do
        @r = Receipt.create!(sale_receipt_params)
        @s1 = @r.transactions.where(inventory_item_id: item1.id).last
        @s2 = @r.transactions.where(inventory_item_id: item4.id).last
        @params = sale_receipt_update_params
        @params[:sale_transactions_attributes][0] = @params[:sale_transactions_attributes][0].merge({id: @s1.id})
        @params[:sale_transactions_attributes][1] = @params[:sale_transactions_attributes][1].merge({id: @s2.id})
      end
      it 'fail to update without second author' do
        @params[:sale_transactions_attributes][1].delete :user_id
        patch :update, id: @r.id, receipt: @params, format: :json, access_token: token.token
        expect(response.status).to eq 400
        expect(JSON.parse(response.body)['errors']).to eq 'Author is required'
      end
      it 'fail to update without both author' do
        @params[:sale_transactions_attributes][0].delete :user_id
        @params[:sale_transactions_attributes][1].delete :user_id
        patch :update, id: @r.id, receipt: @params, format: :json, access_token: token.token
        expect(response.status).to eq 400
        expect(JSON.parse(response.body)['errors']).to eq 'Author is required'
      end
      it 'fail without notes first note' do
        @params[:sale_transactions_attributes][0].delete :notes
        patch :update, id: @r.id, receipt: @params, format: :json, access_token: token.token
        expect(response.status).to eq 400
        expect(JSON.parse(response.body)['errors']).to eq 'Validation failed: Sale transactions notes must be provided when editing'
      end
      it 'fail without both notes' do
        @params[:sale_transactions_attributes][0].delete :notes
        @params[:sale_transactions_attributes][1].delete :notes
        patch :update, id: @r.id, receipt: @params, format: :json, access_token: token.token
        expect(response.status).to eq 400
        expect(JSON.parse(response.body)['errors']).to eq 'Validation failed: Sale transactions notes must be provided when editing'
      end
      it 'fails with mismatch batch and inventory' do
        @params[:sale_transactions_attributes][0]['med_batch_id'] = item3.med_batches.last.id
        patch :update, id: @r.id, receipt: @params, format: :json, access_token: token.token
        expect(response.status).to eq 400
        expect(JSON.parse(response.body)['errors']).to eq 'Validation failed: Sale transactions med batch must match with inventory item'
      end
      it 'reverse sale transactions' do
        @params[:sale_transactions_attributes][0] = @params[:sale_transactions_attributes][0].merge({status: 'deprecated'})
        @params[:sale_transactions_attributes][1] = @params[:sale_transactions_attributes][1].merge({status: 'deprecated'})
        r_total = @r.total

        s1_cnt = @s1.amount
        s1_total = @s1.total_price
        s1_batch_cnt = @s1.med_batch.total_units
        s1_item_cnt = InventoryItem.find(item1.id).amount

        s2_cnt = @s2.amount
        s2_total = @s2.total_price
        s2_batch_cnt = @s2.med_batch.total_units
        s2_item_cnt = InventoryItem.find(item4.id).amount
        patch :update, id: @r.id, receipt: @params, format: :json, access_token: token.token
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['total']).to eq r_total - s1_total - s2_total
        expect(Transaction.find(@s1.id).status).to eq 'deprecated'
        expect(MedBatch.find(@s1.med_batch.id).total_units).to eq s1_batch_cnt + s1_cnt
        expect(InventoryItem.find(item1.id).amount).to eq s1_item_cnt + s1_cnt
        expect(Transaction.find(@s2.id).status).to eq 'deprecated'
        expect(MedBatch.find(@s2.med_batch.id).total_units).to eq s2_batch_cnt + s2_cnt
        expect(InventoryItem.find(item4.id).amount).to eq s2_item_cnt + s2_cnt
      end
      it 'update correctly' do
        r_total = @r.total
        s1_cnt = @s1.amount
        s1_total = @s1.total_price
        barcode1 = @s1.med_batch.barcode
        batch_cnt = @s1.med_batch.total_units
        s1_item_cnt = InventoryItem.find(item1.id).amount
        s2_amt = @s2.amount
        s2_total = @s2.total_price
        s2_new_batch_cnt = item2.med_batches.last.total_units
        s2_new_item_cnt = item2.amount
        barcode2 = item2.med_batches.last.barcode
        s2_old_batch_cnt = @s2.med_batch.total_units
        s2_old_item_cnt = InventoryItem.find(item4.id).amount
        patch :update, id: @r.id, receipt: @params, format: :json, access_token: token.token
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['total']).to eq r_total - s1_total - s2_total + 1875
        expect(MedBatch.find(@s1.med_batch.id).total_units).to eq batch_cnt + s1_cnt - 10
        expect(MedBatch.find(@s1.med_batch.id).barcode).to eq barcode1
        expect(InventoryItem.find(item1.id).amount).to eq s1_item_cnt + s1_cnt - 10
        expect(MedBatch.find(item2.med_batches.last.id).total_units).to eq s2_new_batch_cnt - 15
        expect(MedBatch.find(item2.med_batches.last.id).barcode).to eq barcode2
        expect(MedBatch.find(@s2.med_batch.id).total_units).to eq s2_old_batch_cnt + s2_amt
        expect(InventoryItem.find(item4.id).amount).to eq s2_old_item_cnt + s2_amt
        expect(InventoryItem.find(item2.id).amount).to eq s2_new_item_cnt - 15
      end
    end

  end
end
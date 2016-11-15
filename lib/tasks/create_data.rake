require 'faker'

namespace :data_generation do
  desc 'Generate sale price'
  task :generate_sale_price => :environment do
    s = Store.first
    items = s.inventory_items.without_sale_price.order('RANDOM()').limit(40)
    items.each do |i|
      i.create_sale_price(amount: rand(10..100), discount: rand(5..25))
    end
  end

  desc 'Generate some medicine purchase'
  task :generate_purchases => :environment do
    pkg_list = %w(Bottle Bag Box)
    s = Store.first

    items = s.inventory_items.with_sale_price.order('RANDOM()').limit(40)
    item_ids = items.map(&:id)
    until item_ids.count == 0 do
      attr = []
      portion_id = item_ids.sample(rand(1..3))
      portion_id.each do |id|
        amt_pkg = rand(20..120)
        num_pkg = rand(1..10)
        item = InventoryItem.find(id)
        attr.push({ mfg_date: Faker::Date.between(1.year.ago, 1.month.ago),
                    expire_date: Faker::Date.between(1.year.from_now, 2.year.from_now),
                    package: pkg_list[rand(0..2)],
                    store_id: s.id,             # Same store as logged in user. No need to provide for client with logged in
                    amount_per_pkg: amt_pkg,
                    number_pkg: num_pkg,
                    total_units: amt_pkg*num_pkg,           # Total number of units (package * amount_per_pkg)
                    total_price: rand(10..3000),           # Total price for the whole transaction
                    user_id: s.employees.first.id,
                    category_id: item.category.id,
                    medicine_id: item.itemable.id,    # must include medicine_id
                    inventory_item_id: item.id,       # must include inventory_item_id
                    paid: true
                  })
      end
      s.receipts.create(receipt_type: 'purchase', med_batches_attributes: attr)
      item_ids = item_ids - portion_id
    end
  end

  desc 'Generate some sales'
  task :generate_sales => :environment do
    s = Store.first
    sale_ids = s.inventory_items.with_sale_price.has_stock.order('RANDOM()').limit(200).map(&:id)
    until sale_ids.count == 0 do
      portion_id = sale_ids.sample(rand(1..3))
      time = Faker::Time.between(1.month.ago, Date.today)
      # Build up sale transactions
      attr = []
      portion_id.each do |id|
        item = InventoryItem.find(id)
        amount = rand(1..item.med_batches.available_batches.first.total_units)
        attr.push({
                      amount: amount,
                      delivery_time: time,
                      due_date: time,
                      paid: true,
                      performed: true,
                      user_id: s.employees.first.id,
                      inventory_item_id: id,
                      total_price: amount * item.sale_price.amount,
                      store_id: s.id,
                      med_batch_id: item.med_batches.first.id
                  })
      end
      s.receipts.create(receipt_type: 'sale',
                        sale_transactions_attributes: attr
      )
      sale_ids = sale_ids - portion_id
    end
  end
end